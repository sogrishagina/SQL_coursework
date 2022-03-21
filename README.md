# SQL_coursework
**Coursework «Relational Database basics. MySQL» by Grishagina Olga**

The coursework object is a fictional application “goTogether”. This application helps people to find company for the event. The users can set parameters for a companion and chat with each other. The event search is performed with the date, type, and genre filters. Event organizers can use the app audience in marketing purposes.

The tables of the database gotogether:

1. Users – app users including event organizers (user_type – host)

2. U_profiles – users profiles – additional user information

3. Events – events posted in the app

4. Event_types – defined event types

5. Genre_types – defined event genres

6. Participants – event participants - users who have indicated their participance

7. Partners_request  – request from one user to another

8. Messages – users messages in the chats

9. Galary – media warehouse

The tables were filled with the help of the tool FILLDB. 

*Some fields were filled with random values instead of the actual foreign key to get more realistic result.

*To check the scripts where future events appear it is necessary to exchange the event date for the latest one manually.



The following scrips were written to demonstrate the acquired skills:


* Select query - which city has the most amount of theater-goers

* Select query - what partners user choose gender-wise (male+female, female+female, etc.)

* View - theater events

* View - unpopular events with no users indicated their participance

* View - first name and last name of a user

* Stored procedure - show the user the nearest events which reflect the users’ preferences (recommendation is based on the last event the user participated in)
*future events are necessary for some result

* Stored procedure - show the user the unpopular event which corresponds to the user’s city and the user’s most attended genre
*future events are necessary for some result

* Trigger - the event date change - notify the user

* Trigger - partners request status - notify the user

