{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        implementation =
                            { age , coreutils , gnupg , mkDerivation , writeShellApplication } :
                                mkDerivation
                                    {
                                        installPhase = ''execute-fixture "$out"'' ;
                                        name = "fixture" ;
                                        nativeBuildInputs =
                                            [
                                                (
                                                    writeShellApplication
                                                        {
                                                            name = "execute-fixture" ;
                                                            runtimeInputs = [ age coreutils gnupg ] ;
                                                            text =
                                                                ''
                                                                    OUT="$1"
                                                                    mkdir --parents "$OUT/age"
                                                                    age-keygen --output "$OUT/age/identity"
                                                                    GNUPGHOME="$OUT/gnupg/gnupghome"
                                                                    export GNUPGHOME
                                                                    mkdir --parents "$GNUPGHOME"
                                                                    chmod 0700 "$GNUPGHOME"
                                                                    cat >"$GNUPGHOME/key.conf" <<EOF
                                                                    %no-protection
                                                                    Key-Type: RSA
                                                                    Key-Length: 2048
                                                                    Subkey-Type: RSA
                                                                    Subkey-Length: 2048
                                                                    Name-Real: Nina Nix
                                                                    Name-Email: nina.nix@example.com
                                                                    Expire-Date: 0
                                                                    EOF
                                                                    gpg --batch --gen-key "$GNUPGHOME/key.conf"
                                                                    mkdir --parents "$OUT/gnupg/dot-gnupg"
                                                                    gpg --homedir "$GNUPGHOME" --export-ownertrust --armor > "$OUT/gnupg/dot-gnupg/ownertrust.asc"
                                                                    gpg --homedir "$GNUPGHOME" --export-secret-keys --armor > "$OUT/gnupg/dot-gnupg/secret-keys.asc"
                                                                    rm --recursive --force "$GNUPGHOME"
                                                                '' ;
                                                        }
                                                )
                                            ] ;
                                        src = ./. ;
                                    } ;
                    } ;
            } ;
}