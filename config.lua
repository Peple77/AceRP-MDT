Config = {
  Label = 'County Records', -- Label for the MDT
  ProfilesLabel = 'County Profiles', -- Label for the profiles tab
  ReportsLabel = 'County Reports', -- Label for the reports tab
  WarrantsLabel = 'Active Warrants', -- Label for the warrants tab
  Year = '1900', -- The year your server is based in for the date on the reports
  CommandGrade = 3, -- Minimum grade for supervisors (Gives them the ability to delete any report)
  UseCommand = true, -- Allow players to use the command to open the mdt, otherwise they have to interact at a location
  Command = 'mdt', -- Command to open the mdt (Only works if UseCommand = true)
  Prop = 'p_book03x', -- Prop for the interact locations
  Locations = { -- Locations of interact for the mdt
    vec4(2507.5090, -1308.8459, 48.7000, 144.3056),
    vec4(1361.8623, -1303.9835, 77.5000, 262.8849),
    vec4(-277.2248, 807.3371, 119.1718, 245.6663),
    vec4(-762.4330, -1267.6000, 43.8428, 343.4424),
    vec4(-1807.6886, -349.0573, 164.4476, 347.7998),
  },
}

