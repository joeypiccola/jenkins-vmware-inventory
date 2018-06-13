$ErrorActionPreference = 'stop'
Write-Error 'fu'

$vcenter_user = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_USR')).value
$vcenter_pass = (Get-ChildItem -Path ('env:cred_vcenter_adpiccolaus_PSW')).value

$secpasswd = ConvertTo-SecureString $vcenter_pass -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($vcenter_user, $secpasswd)

function Get-DatastoreClusters
{
	param
	(
		[CmdletBinding()]
		[Parameter(Mandatory)]
		[string]$Cluster
	)

	begin
	{
		# verify we can connect to the provided cluster.
		if (!($GetCluster = Get-Cluster -Name $Cluster))
		{
			Write-Error "Unable to connect to `"$Cluster`" to get DatastoreClusters"
		}
	}
	process
	{
		$pods = Get-Cluster $Cluster | Get-Datastore | ?{ $_.ParentFolderId -like 'StoragePod-group-*' } | sort -Unique -Property ParentFolderID
		Write-Verbose "Found $($pods.count)x datastore cluster on $cluster cluster."

        # if we have datastore clusters, use those. else, just go to the datastores
        if ($pods)
        {
            foreach ($pod in $pods)
		    {
			    $GetPod = Get-DatastoreCluster -Id $pod.ParentFolderId | select Name, FreeSpaceGB, CapacityGB
			    Write-Output $GetPod
		    }
        }
        else
        {
            $datastores = Get-Cluster $Cluster | Get-Datastore
            foreach ($datastore in $datastores)
		    {
			    $ds = $datastore | select Name, FreeSpaceGB, CapacityGB
			    Write-Output $ds
		    }
        }
	}
	end {}
}

function Get-VDPortGroups
{
	param
	(
		[CmdletBinding()]
		[Parameter(Mandatory)]
		[string]$Cluster
	)

	begin
	{
		# verify we can connect to the provided cluster.
		if (!($GetCluster = Get-Cluster -Name $Cluster))
		{
			Write-Error "Unable to connect to `"$Cluster`" to get DatastoreClusters"
		}
	}
	process
	{
		$clusterHost = get-cluster -Name $Cluster | get-vmhost | ?{ $_.ConnectionState -eq 'Connected' } | Get-Random -Count 1
		$clusterPortgroups = $clusterHost | Get-VDSwitch | Get-VDPortgroup | select Name, VlanConfiguration
		Write-Output $clusterPortgroups
	}
	end {}
}

$inventory_col = @()
$vcenters = @('vcenter.ad.piccola.us')

$vcenters_col = @()
foreach ($vcenter in $vcenters)
{
	try {
		Write-Host "Connecting to $vcenter" -ForegroundColor Magenta
		Connect-VIServer -Server $vcenter -Credential $mycreds | Out-Null
		Write-Host "`tGetting datacenters on $vcenter" -ForegroundColor Cyan
		$datacenters = (Get-Datacenter).Name
		$datacenters_col = @()
		foreach ($datacenter in $datacenters)
		{
			Write-Host "`t`tGetting clusters on $vcenter\$datacenter" -ForegroundColor Green
			$clusters = (Get-Cluster -Location $datacenter).name
			$clusters_col = @()
			foreach ($cluster in $clusters)
			{
				Write-Host "`t`t`tGetting datastoresclusters on $vcenter\$datacenter\$cluster" -ForegroundColor Yellow
				$datastoresclusters = Get-DatastoreClusters -Cluster $cluster
				Write-Host "`t`t`tGetting vdportgroups on $vcenter\$datacenter\$cluster" -ForegroundColor Yellow
				$vdportgroups       = Get-VDPortGroups -Cluster $cluster

				$cluster_object = [pscustomobject]@{
					name               = $cluster
					datastoresclusters = $datastoresclusters
					vdportgroups       = $vdportgroups
				}
				$clusters_col += $cluster_object
			}

			$datacenter_object = [pscustomobject]@{
				name     = $datacenter
				clusters = $clusters_col
			}
			$datacenters_col += $datacenter_object
		}

		$vcenter_object = [pscustomobject]@{
			name        = $vcenter
			datacenters = $datacenters_col
		}
		$vcenters_col += $vcenter_object
	} catch {
		Write-Error $_.Exception.Message
	} finally {
		Write-Host "Disconnecting from $vcenter" -ForegroundColor Magenta
		Disconnect-VIServer -Confirm:$false
	}
}

$inventory_object = [pscustomobject]@{
    vcenters = $vcenters_col
}
$inventory_col += $inventory_object

$inventory_col | ConvertTo-Json -Depth 8 | add-content -Path .\vcen_inventory_$(get-date -f Mddyy-HHmmss).json