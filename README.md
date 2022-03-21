# zelfologi
A case study related to a health care service provider Zelfologi
There are availability, bookings, and ad-hoc blocks of 6 practitioners.

(1) Write a query to prepare a visualization data mart to cover the period between 2022-02-21 and 2022-02-25. Working hours information is specified for weekly calculations, but we should apply this only for 5 working days. It is recommended to upload the datasets to any database. SQL dialect isn't important, but you can make sure that your query is flawless.

(2) Prepare the visualization in Google Data Studio. As a business user I should have:
- a percent of available practitioners for each concrete hour in a week
- an aggregated information about the available hours for the whole week and concrete days
- the opportunity to filter practitioners and see the general view for all practitioners

You are free to use any visualizations available in GDS.
Let's think like the time of practitioners is granulated by hours. So the treatment sessions and breaks should be aliquot to 1 hour.
