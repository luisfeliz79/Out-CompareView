######################################################
# Out-CompareView
#
# Compare objects side by side
# By Luis Feliz (lufeliz@microsoft.com)
#
# $Objects | Out-CompareView
#                -TitleProperty to specify a particular property to use as title
#                -GridView - use the Out-GridView control to show results
#
######################################################
function Out-CompareView  {
[CmdletBinding()]

Param(
   [Parameter(ValueFromPipeline)]$objects,
   [String]$TitleProperty,
   [Switch]$GridView
)

Begin {
    
    #$VerbosePreference="Continue"
    
    $Items=@()
    $Props=@()
    $AllObjects=@()
 
}

Process {

    if (-not $Props) {
        # Get all the Properties and NoteProperties for the first object   
        $Props=($Objects | get-member | where MemberType -match "Property|NoteProperty").Name
        if ($props.count -lt 1) { Write-Error "The objects have no Properties or NoteProperties";break }

        if (-not $TitleProperty) {

        #No Title Property specified, so lets pick one from the list of $props
        $DefaultTitlesToTry="ObjectID","ID","Name","DisplayName","UserPrincipalName","email","UPN","ImmutableID"

            ForEach ($title in $DefaultTitlesToTry) {

                if ($Props -contains $title) {
                    #once we find one, set it to that.
                    Write-Verbose "Auto Picking $title as TitleProperty"
                    $TitleProperty=$title
                   
                }

                if ($TitleProperty) {break}

            }
            
        }

        #However, if the user did specify a title property, lets make sure it is in the list of $props
        if ($Props -notcontains $TitleProperty) { 
            Write-error "The Property $TitleProperty is not found on this object. Try specifying one of these : $Props";break }
        }


    #We need to get all the objects first, so $AllObjects will hold them
    $AllObjects+=$objects
    
  

}

End {

    #For each property, and each object, add a row with the values
    $Props | % {

    $Prop=$_
    $Rows=@()

    #First column should be Attributes
    $Rows=([ordered]@{"Attributes"=$Prop})

    #for each object, add a row to $rows 
    $AllObjects | % {
    
        $Rows.add($_.$TitleProperty, $_.$Prop)
          
    }
    
    #Then add Powershell object for each property
    $items+=New-Object -TypeName psobject -Property $Rows

}
    #Finally make the data available
    if ($GridView) {
        $items | Out-GridView
    } else {
        $items
    }

}



} #endfunction

