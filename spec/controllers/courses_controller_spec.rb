require 'rails_helper'

describe Api::V1::CoursesController, type: :controller do
  let(:semester) { FactoryGirl.create(:semester) }
  let(:user) { semester.graduation_plan.advisee.user }

  before do
    sign_in user
  end

  describe 'POST /api/v1/semesters/:semester_id/courses' do
    it 'creates a new course' do
      name = 'PSY 100'
      credits = 2.51
      post :create, semester_id: semester.id, course: {
        name: name,
        credits: credits
      }

      json = parse_json(response)

      expect(json['message']).to include('Course created')
      expect(json['course']['id']).not_to be(nil)
      expect(json['course']['name']).to eq(name)
      expect(json['course']['credits']).to eq((credits * 10).round)
    end

    it 'returns errors if the course is invalid' do
      post :create, semester_id: semester.id, course: { name: '' }

      json = parse_json(response, :bad_request)

      expect(json['message']).to include('There was a problem')
      expect(json['errors']).to include("Name can't be blank")
    end
  end

  describe 'PUT /api/v1/courses/:course_id' do
    it 'moves a course to another semester' do
      course = FactoryGirl.create(:course, semester: semester)
      new_semester = FactoryGirl.create(:semester,
                                        graduation_plan: semester.graduation_plan)

      put :update, id: course.id, new_semester_id: new_semester.id

      json = parse_json(response)

      expect(json['message']).to eq('Course moved!')
      expect(json['course']['semester_id'].to_i).to eq(new_semester.id)
    end

    it 'returns an error message if there was no new semester' do
      course = FactoryGirl.create(:course, semester: semester)

      put :update, id: course.id, new_semester_id: ''

      json = parse_json(response, :bad_request)

      expect(json['message']).to include('There was a problem')
      expect(json['errors']).to include("Semester can't be blank")
    end

    it 'returns an error if the new semster does not exist' do
      course = FactoryGirl.create(:course, semester: semester)

      put :update, id: course.id, new_semester_id: 999
      json = parse_json(response, :bad_request)

      expect(json['message']).to include('There was a problem')
      expect(json['errors']).to include("Semester can't be blank")
    end
  end

  describe 'DELETE /api/v1/courses/:course_id' do
    it 'deletes a course' do
      course = FactoryGirl.create(:course, semester: semester)

      delete :destroy, id: course.id

      json = parse_json(response)

      expect(json['message']).to include('Course deleted')
      expect(json['course_id'].to_i).to eq(course.id)
    end
  end
end
