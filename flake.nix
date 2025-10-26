{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { age , coreutils , failure , gnupg , mkDerivation , writeShellApplication } :
                        {
                            implementation =
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
                                                            runtimeInputs = [ age coreutils gnupg uuidgen ( failure "0118ba19" ) ] ;
                                                            text =
                                                                ''
                                                                    OUT="$1"
                                                                    mkdir --parents "$OUT/age/identity"
                                                                    age-keygen --output "$OUT/age/identity/private"
                                                                    age-keygen -y "$OUT/age/identity/private" > "$OUT/age/identity/public"
                                                                    mkdir --parents "$OUT/age/decrypted"
                                                                    uuidgen | sha512sum | cut --characters 1-128 > "$OUT/age/decrypted/known-hosts"
                                                                    mkdir --parents "$OUT/age/encrypted"
                                                                    PUBLIC_KEY="$( age-keygen -y "$OUT/age/identity/private" )" || failure public key
                                                                    age --recipient "$PUBLIC_KEY" --output "$OUT/age/encrypted/known-hosts"
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