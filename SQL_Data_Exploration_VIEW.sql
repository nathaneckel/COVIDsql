/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[RollingPeopleVaccinated]
  FROM [Portfolio].[dbo].[PercentPopulationVaccinated]

  --END 1:14 - need to upload to Git