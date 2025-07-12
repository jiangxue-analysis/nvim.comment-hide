# Define inputs: testers framework and self-reference (flake self)
{ testers, self }:

# Create a NixOS virtual machine test
testers.nixosTest {
  name = "vm-test";  # Name of the test

  # Define the nodes for the test (in this case, just a server)
  nodes.server = { pkgs, ... }: {

    # Environment configuration
    environment = {
      # Files to be placed in /etc
      etc = {
        # Script that runs netcat to serve HTTP responses
        "nc.sh" = {
          text = ''
            #!/bin/sh
            while true; do
              ${pkgs.netcat}/bin/nc -l "$PORT" <<'EOF'
            HTTP/1.1 200 OK
            Content-Length: 13
            Connection: close

            Hello, world!
            EOF
            done
          '';
          mode = "0755";  # Make the script executable
        };

        # Keter configuration file
        "keter.yaml".text = ''
          stanzas:
            - type: webapp
              exec: ../nc.sh  # Reference to our netcat script
              hosts:
                - localhost
        '';

        # Deployment script to bundle and deploy the application
        "deploy.sh" = {
          text = ''
            mkdir -p /tmp/bundle/config
            cp /etc/nc.sh /tmp/bundle/nc.sh
            cp /etc/keter.yaml /tmp/bundle/config/keter.yaml
            tar -C /tmp/bundle -czvf /tmp/nc.keter .
            cp /tmp/nc.keter /opt/keter/incoming
          '';
          mode = "0755";  # Make the script executable
        };
      };

      # Packages to be available system-wide
      systemPackages = [ pkgs.netcat ];
    };

    # Import additional NixOS modules
    imports = [
      ./keter.nix  # Import Keter service configuration
    ];

    # Nix configuration settings
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    # Keter service configuration
    services.keter-ng = {
      enable = true;  # Enable the Keter service
      package = self.packages.x86_64-linux.keter;  # Use Keter from our flake
      globalKeterConfig = ''
        root: /opt/keter
        rotate-logs: true
        listeners:
          - host: "*4"  # Listen on all IPv4 interfaces
            port: 80    # Standard HTTP port
      '';
    };
  };

  # Test script that runs in the virtual machine
  testScript = ''
    # Start the server node
    server.start()
    
    # Wait for Keter service to start
    server.wait_for_unit("keter-ng.service")
    
    # Wait for port 80 to be open
    server.wait_for_open_port(80)
    
    # Execute the deployment script
    server.succeed(". /etc/deploy.sh")
    
    # Wait for deployment to complete
    server.sleep(10)
    
    # Verify the web application responds correctly
    server.succeed("curl localhost | grep 'Hello, world!'")
    
    # Check for absence of file lock errors in logs
    server.succeed("! grep -q 'file is locked' /opt/keter/log/keter.log")
    
    # Test file watching functionality
    server.succeed("touch /opt/keter/incoming/nc.keter")
    server.sleep(10)
    
    # Verify no file lock errors occurred after touching the file
    server.succeed("! grep -q 'file is locked' /opt/keter/log/keter.log")
  '';
}
