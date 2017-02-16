# Fix-UnquotedPathways
Used to fix "Unquoted Pathways"

I took the Technet Script that fixes the Unquoted Pathways and added the ability to find service paths that are unquoted. This script could be modified to find all computers on a certain domain fix the service paths. The two functions are:

Fix-ServicePath 
  This is the original Technet Script with a few tweeks that include quoting paths for exe, vbs, and bat files.
  
Find-ServicePaths 
  Does exactly what the function says. It finds the services paths that are unquoted on a single endpoint. 
