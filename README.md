# Out-CompareView

 Compare objects in an array side by side
 By Luis Feliz (lufeliz_micro_soft_com)

## Parameters
	-TitleProperty <string> to specify a particular property to use as title (must be unique values)
	-ExcludeProperty <Array> Don't show these properties
	-IncludeProperty <Array> Only show these properties
    -ExportCSVFile <filename> to output to a CSV file
    -ExportCliXML <filename> to output the object to a CLI XML file
    
    Note: Default is to output to a GridView

## Examples
	
### Get All AzureAD Users with the name Luis and compare all attributes on a gridview

     Get-AzureADUser -Searchstring "Luis" | Out-CompareView


### Get All AzureAD Users with the name Luis and compare all attributes on  a gridview, using UserPrincipalName as the title header

     Get-AzureADUser -Searchstring "Luis" | Out-CompareView -TitleProperty UserPrincipalName

### Get All AzureAD Users with the name Luis and compare all attributes on  a gridview, using UserPrincipalName as the title header

     Get-AzureADUser -Searchstring "Luis" | Out-CompareView -TitleProperty UserPrincipalName

