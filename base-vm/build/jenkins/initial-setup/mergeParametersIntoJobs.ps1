Get-Content config.xml | Select-String '(?<=@\{)(.+)(?=\})' | ForEach-Object {
    Get-Content active_choice_parameters/$_.Matches[0].Groups[1].Value
}
