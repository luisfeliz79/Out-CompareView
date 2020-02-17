######################################################
# Out-CompareView
#
# Compare objects in an array side by side
# By Luis Feliz (lufeliz_micro_soft_com)
#
# $Objects | Out-CompareView
#                -TitleProperty to specify a particular property to use as title (must be unique values)
#                -ExportCSVFile <filename> to output to a CSV file
#                -ExportCliXML <filename> to output the object to a CLI XML file
#                
#                Default is to output to a GridView
#
########################################################################################################
function Out-CompareView  {
[CmdletBinding()]

Param(
   [Parameter(ValueFromPipeline)]$objects,
   [String]$TitleProperty,
   [string]$ExportCSVFile,
   [string]$ExportCliXMLFile,
   [switch]$ReturnObject,
   [Array]$ExcludeProperty,
   [Array]$IncludeProperty
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
        [System.Collections.ArrayList]$Props=($Objects | get-member | where MemberType -match "Property").Name

        $ExcludeProperty | ForEach-Object {

              if ($Props -contains $_) {

                    $SpecifiedAttrib=$_
                    $AttribCorrectCase=($Props | where {$_ -eq $SpecifiedAttrib})
                #Remove using this method, To deal with case sensitivity
                
                $Props.Remove($AttribCorrectCase)
                Write-Verbose -Message "Removing attribute $AttribCorrectCase as requested"
                
              
              }

        }

        if ($IncludeProperty) { 
        
            $Props=$IncludeProperty
                Write-Verbose -Message "Only using these Attributes: $($IncludeProperty -join ", ")"
        
        
        }

        

        if ($props.count -lt 1) { Write-Error "The objects have no *Properties ";break }

        if (-not $TitleProperty) {

        #No Title Property specified, so lets pick one from the list of $props
        $DefaultTitlesToTry="ObjectID","ID","Name","DisplayName","UserPrincipalName","email","UPN","ImmutableID","Subject"

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
            Write-error "The Property $TitleProperty is not found on this object. Try specifying one of these : $Props";exit }
        }


    #We need to get all the objects first, so $AllObjects will hold them
    $AllObjects+=$objects

    write-verbose "Adding Object: $($objects.$TitleProperty)"
    
  

}

End {

    #For each property, and each object, add a row with the values
    $Props | ForEach-Object {

    $Prop=$_
    $Rows=@()

    #First column should be Attributes
    $Rows=([ordered]@{"Attributes"=$Prop})

    #for each object, add a row to $rows 
    $AllObjects | ForEach-Object {
    
    Try {
        $Entry=$_
        $Rows.add($_.$TitleProperty, ($_.$Prop -join ", ").trim()) 
    }
    catch {
        Write-warning "Error Adding $($entry.$TitleProperty) - $($Entry.$Prop), this may be due to duplicate entries"
        #Nothing to do, just keep going
    }      
    }
    
    #Then add Powershell object for each property
    $items+=New-Object -TypeName psobject -Property $Rows

}
    #Finally make the data available

    if ($ExportCSVFile) {
    
        $items | export-CSV $ExportCSVFile -NoTypeInformation
        Write-Verbose "Wrote $ExportCSVFile"
        break
    }

    if ($ExportCliXMLFile) {
    
        $items | Export-Clixml $ExportCliXMLFile
        Write-Verbose "Wrote $ExportCliXMLFile"

        break
    }

    if ($ReturnObject) {

        return $Items
        break
    }

    $Items | Out-GridView

}



} #endfunction
