{ ... }:

let
  name = "faamac";
in

{
  networking.computerName = name;
  networking.hostName = name;
  networking.localHostName = name;
}
