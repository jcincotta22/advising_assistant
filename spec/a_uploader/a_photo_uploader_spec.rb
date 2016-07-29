require 'rails_helper'
require 'pry'

describe 'AdviseePhotoUploader' do
  it 'calls fog for storage in production' do
    allow(Rails).to receive_message_chain(:env, :test?).and_return(false)
    expect(CarrierWave::Uploader::Base).to receive(:storage).with(:fog)
    load File.expand_path('./app/uploaders/advisee_photo_uploader.rb')
  end

  it 'calls file for storage in test' do
    allow(Rails).to receive_message_chain(:env, :test?).and_return(true)
    expect(CarrierWave::Uploader::Base).to receive(:storage).with(:file)
    load File.expand_path('./app/uploaders/advisee_photo_uploader.rb')
  end
end