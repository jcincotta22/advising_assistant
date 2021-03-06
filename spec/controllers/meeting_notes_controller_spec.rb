require 'rails_helper'

describe Api::V1::MeetingNotesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:meeting) { FactoryGirl.create(:meeting, user: user) }

  before do
    sign_in user
  end

  describe 'GET /api/v1/meetings/:meeting_id/meeting_notes' do
    it 'returns all notes for an advisee' do
      notes = FactoryGirl.create_list(:note, 3, noteable: meeting)

      get :index, meeting_id: meeting.id

      json_response = parse_json(response)
      ids = get_note_ids(json_response)

      notes.each do |note|
        expect(ids).to include(note.id)
      end
    end

    it 'orders notes by the time they were last updated' do
      old_note = FactoryGirl.create(:note,
                                    noteable: meeting,
                                    updated_at: DateTime.new(2010, 5, 1, 8, 0))
      new_note = FactoryGirl.create(:note,
                                    noteable: meeting,
                                    updated_at: DateTime.new(2016, 7, 20, 8, 0))
      note = FactoryGirl.create(:note,
                                noteable: meeting,
                                updated_at: DateTime.new(2016, 7, 19, 8, 0))

      get :index, meeting_id: meeting.id

      json_response = parse_json(response)
      ids = get_note_ids(json_response)

      expect(ids).to eq([new_note.id, note.id, old_note.id])
    end
  end

  describe 'POST /api/v1/meetings/:meeting_id/meeting_notes' do
    let(:note_body) { 'This is an awesome note' }

    it 'creates a new note if a valid note is provided' do
      post :create,
           meeting_id: meeting.id,
           note: { body: note_body }

      json_response = parse_json(response)

      expect(json_response['message']).to include('Note created')

      note = json_response['note']
      expect(note['body']).to eq(note_body)
      expect(note['id']).not_to be(nil)

      db_note = Note.first
      expect(db_note.body).to eq(note_body)
      expect(db_note.noteable_id).to eq(meeting.id)
    end

    it 'returns errors if the note is invalid' do
      post :create, meeting_id: meeting.id, note: { body: '' }

      json_response = parse_json(response, :bad_request)

      expect(json_response['message']).to include('There were problems '\
                                                  'creating that note')
      errors = json_response['errors']

      expect(errors).to include("Body can't be blank")
    end
  end
end
