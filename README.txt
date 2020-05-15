This is an iOS app for viewing COVID-19 statistics for various countries, regions, and cities. 

Click the "Add Location" button to add a new location to the table that you would like to see statistics for. The country name must be the 3-letter ISO code for the country. The region name must be the full name of the region (e.g. "California" or "Quebec"). The city name must be the full name of the city. Only the country is required.

You can also use your location services instead to populate the location fields based on your phone's geographical location. The location may not exist in the COVID-19 statistics API, such as Cupertino (created by user Axisbits at https://rapidapi.com/axisbits-axisbits-default/api/covid-19-statistics/details). If this is the case, the app will not let you add the location. Locations that are added persist between sessions using CoreData.

After adding locations to the table view, click on any location to view statistics for it. The next view shows confirmed cases and deaths for COVID-19 in that location up to the date that is shown on the Date Picker. After changing the date, click the Update Date button to update the statistics.

By pressing the buttons for the graphs at the bottom of this view, you can view Core Graphics graphs of the confirmed cases and deaths for the 7 or 30 days leading up to and including the date shown on the Date Picker. This may take a few seconds to load.