import React, { Component, PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import Flash from '../lib/Flash';
import moment from 'moment-timezone/builds/moment-timezone-with-data';
import Meeting from './Meeting';
import NewMeeting from './NewMeeting';
import Loader from './Loader';

class Meetings extends Component {
  constructor(props) {
    super(props);

    this.state = {
      newMeeting: this.resetMeeting(),
      newMeetingErrors: [],
      meetings: [],
      showNewMeetingForm: false,
      loading: false
    }

    this.getMeetings = this.getMeetings.bind(this);
    this.changeDescription = this.changeDescription.bind(this);
    this.changeDateTime = this.changeDateTime.bind(this);
    this.changeDuration = this.changeDuration.bind(this);
    this.saveMeeting = this.saveMeeting.bind(this);
    this.renderMeetings = this.renderMeetings.bind(this);
    this.onMeetingDelete = this.onMeetingDelete.bind(this);
    this.toggleFormVisibility = this.toggleFormVisibility.bind(this);
    this.renderNewMeetingForm = this.renderNewMeetingForm.bind(this);
    this.renderToggleFormButton = this.renderToggleFormButton.bind(this);
  }

  componentDidMount() {
    this.setState({ loading: true });
    this.getMeetings();
  }

  getMeetings() {
    $.ajax({
      url: `/api/v1/advisees/${this.props.adviseeId}/meetings`,
      method: 'GET'
    })
    .done((data) => {
      this.setState({ meetings: data.meetings });
    })
    .always(() => {
      this.setState({ loading: false });
    });
  }

  resetMeeting() {
    return {
      description: '',
      start_time: '',
      duration: 15,
      timezone: moment.tz.guess()
    }
  }

  changeDescription(event) {
    let meeting = this.state.newMeeting;
    meeting.description = event.target.value;
    this.setState({ newMeeting: meeting });
  }

  changeDateTime(datetime) {
    let meeting = this.state.newMeeting;
    meeting.start_time = datetime;
    this.setState({ newMeeting: meeting });
  }

  changeDuration(event) {
    let meeting = this.state.newMeeting;
    meeting.duration = event.target.value;
    this.setState({ newMeeting: meeting });
  }

  renderMeetings() {
    if(this.state.meetings.length == 0){
      return (
        <h5 className="no-meetings">
          There are no meetings
        </h5>
      );
    }

    return this.state.meetings.map((meeting) => {
      return <Meeting key={meeting.id}
                      meeting={meeting}
                      onDelete={this.onMeetingDelete} />;
    });
  }

  saveMeeting(event) {
    $.ajax({
      url: `/api/v1/advisees/${this.props.adviseeId}/meetings`,
      method: 'POST',
      data: {
        meeting: this.state.newMeeting
      }
    })
    .done((data) => {
      let meetings = this.state.meetings;
      meetings.unshift(data.meeting);
      let meeting = this.state.newMeeting;
      meeting.description = '';
      this.setState({ meetings: meetings,
                      newMeeting: meeting,
                      newMeetingErrors: [] });
      Flash.success('Meeting created!');
    })
    .fail((response) => {
      let data = response.responseJSON;
      Flash.error(data.message);
      this.setState({ newMeetingErrors: data.errors });
    });
  }

  onMeetingDelete(meeting) {
    let meetings = this.state.meetings;

    meetings = meetings.filter((currentMeeting) => {
      return meeting.id !== currentMeeting.id;
    });

    this.setState({ meetings: meetings });
  }

  toggleFormVisibility() {
    let currentVisibilty = this.state.showNewMeetingForm;

    this.setState({ showNewMeetingForm: !currentVisibilty });
  }

  renderNewMeetingForm() {
    if(this.state.showNewMeetingForm){
      return (
        <NewMeeting key="1"
                    meeting={this.state.newMeeting}
                    errors={this.state.newMeetingErrors}
                    changeDescription={this.changeDescription}
                    changeDateTime={this.changeDateTime}
                    changeDuration={this.changeDuration}
                    saveMeeting={this.saveMeeting} />
      );
    } else {
      return null;
    }
  }

  renderToggleFormButton() {
    let buttonIcon = <i className="material-icons left">add</i>;
    let buttonText = 'Add New Meeting';
    if(this.state.showNewMeetingForm){
      buttonIcon = null;
      buttonText = 'Hide';
    }

    return (
      <div className="center-align">
        <button className="btn primary" onClick={this.toggleFormVisibility}>
          {buttonIcon}
          {buttonText}
        </button>
      </div>
    );
  }

  render() {
    return (
      <div className="meetings-container">
        {this.renderToggleFormButton()}
        <ReactCSSTransitionGroup transitionName="generic"
                                 transitionEnterTimeout={500}
                                 transitionLeaveTimeout={300}
                                 transitionAppear={true}
                                 transitionAppearTimeout={500}>
          {this.renderNewMeetingForm()}
        </ReactCSSTransitionGroup>
        <Loader active={this.state.loading}>
          <div className="meetings">
            <ReactCSSTransitionGroup transitionName="generic"
                                     transitionEnterTimeout={500}
                                     transitionLeaveTimeout={300}
                                     transitionAppear={true}
                                     transitionAppearTimeout={500}>
              {this.renderMeetings()}
            </ReactCSSTransitionGroup>
          </div>
        </Loader>
      </div>
    );
  }
}

export default Meetings;
