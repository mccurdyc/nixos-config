{ ... }:

let
  name = "paamac";
in

{
  networking.computerName = name;
  networking.hostName = name;
  networking.localHostName = name;
}
