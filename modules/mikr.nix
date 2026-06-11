{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mikr = {
    isNormalUser = true;
    description = "Mikkel";
    extraGroups = [ "networkmanager" "wheel" ];
    initialHashedPassword = "$6$98sQ0D0M5Gl5Rxoi$VA9qFqijQa1myZOK/85JchF6Ii1kwAkiZQVKEUzS27/tFloaa11/2ahwarnvz7b3HvMuCCTpeXMwvaEeQr8T71";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK16+6/jzCvp3Sthg0S0JY2syS3ypa8kxkLr34mJghisvIr4o3G3o0PAaB9rZHd/M2cmZYP7/bkXt/QpWWjaOlztQvYd3oZ9sAl5Omt0kKcmzdsiz5om+0sBfpHVBgkC+nBFgF3+/e2hMh8Z7xqPfbFhpZjBDozh2HflN09xwt5K1fREflxLZfQl9VYLbwRhRtlpmPOXmMWO+6jF90tggvLs926zIV1oe+cQbxrdhPyq09fCAvZKPOfurrJBjB+EZ2IJIwhL/GpkANOBp3TmoES/FVkvzkYrdHq9DVqq4rm1L5FK85ssQK6Fk0VVh7fWknIoMzLRnPRFoMBcb+7dU2TrwY0IIaepulrWtGSSmSjzQXkEP9KnCoFtHxSj5qSgYX1PjSiXoVAEULhQdCQzp2DEwDbiwDKbaZ1VBCwH4TDII9zWYJ355CguD03hWrdrpSXbWE3JFHZtT/ZYK2J23yZEiWY6wMW5YvGSY6kRZzpg6bnCmxi1PlRuLmlWDR/dUTSp+WMmAv/wnbHyLJD5WGJnmSXlI+xYsdbl+VjUpOylBEOR+wWKNww9UTS6U+aYZJ8bh5tDSvgxrg6qJoij/UlG3yQUX3hRi/iWctETJ3PSTRyFY5QNZjhnaglR+NKDn0vvZ6GF759wQ9gkOoYEuXmHFHKaymvowE+qIGXhgSnw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwBqaLrj5+vtBI3WV3oYStU1MsplwHU8D/mwSdQxbGzxHujw7xTPv1fnKWuxEkf/dLBnXIHi6Pp2Opdcb+07UQ6rbiuqUOzRpIfUQ6+HbnjlK9olyurdp+1JcK53Xd30Hqi8nLnhohgscEqoYE+Nqe/AvRsMNzrZu0R8QPOChxISvmR39hDWXZteWUPH3Dg3sq0iSM73aWcE8nOc7kQPXMxzbTBh6K95Dy3c4CfV/A4KzDQo3Qt8hj8A8f/tE215PfNFF959aJgAqnzElVvwwtC21xRQAn4HXTIZorSXOlTSQVvOJWcGTsPpsjh66pp/SOlp010G9meQaPaxDijbRg5diS3E2knNYN69v8Ucz0ZItGvTF8t4ss9GllBQaVCNbFryEkE4jxIrymc/ougX9hrm6VRQ6hTP1KiyLil62pkC2cTnaaYatnUwIT2/GtT8s1uJeeI9Vw7whisMG3jFz+Cs44zk/S+JqsGgJq2QcD0M2FKATC7DQcUpyC9LtuPHR6WE+v9Api2FypM6MS0bhy57bkMFNSJnFfy+gFfP2S/cMsUfOEbtRcmcnDUfpvDx2tD1ZqZUrV1ETnv1422gthc+X3SXHuewXqDvq5xzrGSsIXZ0LBRW/qtDcaWKpzQ3GAONmLk7l17Z4rT2QCnvZOu0j7FSt4epD1CUzlSS8Fcw=="
      ];
  };
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mikr";
}
