import 'babel-polyfill';
import React from 'react';
import ReactDOM from 'react-dom';
import AdviseeSearch from './components/AdviseeSearch';
import Notes from './components/Notes';
import Meetings from './components/Meetings';
import MeetingTime from './components/MeetingTime';

$(function() {
  let adviseeSearch = document.getElementById('advisee-search');

  if(adviseeSearch){
    ReactDOM.render(
      <AdviseeSearch />,
      adviseeSearch
    );
  }

  let adviseeNotes = document.getElementById('advisee-notes');

  if(adviseeNotes){
    let adviseeId = $('#advisee-data').data('id');

    ReactDOM.render(
      <Notes noteableType="advisees"
             noteableId={adviseeId}
             controller="advisee_notes" />,
      adviseeNotes
    );
  }

  let adviseeMeetings = document.getElementById('advisee-meetings');

  if(adviseeMeetings){
    let adviseeId = $('#advisee-data').data('id');

    ReactDOM.render(
      <Meetings adviseeId={adviseeId} />,
      adviseeMeetings
    );
  }

  let meetingNotes = document.getElementById('meeting-notes');

  if(meetingNotes){
    let meetingId = $('#meeting-data').data('id');

    ReactDOM.render(
      <Notes noteableType="meetings"
             noteableId={meetingId}
             controller="meeting_notes" />,
      meetingNotes
    );
  }

  let meetingTime = document.getElementById('meeting-time');

  if(meetingTime){
    let meetingStart = $('#meeting-data').data('start');
    let meetingEnd = $('#meeting-data').data('end');

    ReactDOM.render(
      <MeetingTime startTime={meetingStart} endTime={meetingEnd} />,
      meetingTime
    );
  }
});
