@{
    # Node specific data
    AllNodes = @(    
        # Data  for all the nodes that will be created by the full production scenario.

            @{
            NodeName          = "localhost"           
            PSDscAllowPlainTextPassword = $true;
                              
            };        
    );
}
