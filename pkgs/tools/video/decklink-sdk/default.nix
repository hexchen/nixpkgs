{ stdenv
, cacert
, curl
, runCommandLocal
, unzip
, lib
}:

stdenv.mkDerivation rec {
  pname = "decklink-sdk";
  version = "12.5.1";

  # yes, the below download function is an absolute mess.
  # blame blackmagicdesign.
  src = runCommandLocal "${pname}-${version}-src.zip"
    rec {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-RxESYIjm119ZA8sMxUqXIFStzpmbv4S88rnPXn0/spc=";

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;

      nativeBuildInputs = [ curl ];

      # ENV VARS
      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

      # from the URL that the POST happens to, see browser console
      DOWNLOADID = "16b195b1b9c54c0089aaa3ef0757a457";
      # from the URL the download page where you have to register
      REFERID = "8dbc1e1a31924df7ad46cfa4a8e08ce1";
      SITEURL = "https://www.blackmagicdesign.com/api/register/us/download/${DOWNLOADID}";

      USERAGENT = builtins.concatStringsSep " " [
        "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.targetPlatform.linuxArch})"
        "AppleWebKit/537.36 (KHTML, like Gecko)"
        "Chrome/77.0.3865.75"
        "Safari/537.36"
      ];

      REQJSON = builtins.toJSON {
        "firstname" = "NixOS";
        "lastname" = "Linux";
        "email" = "someone@nixos.org";
        "phone" = "+31 71 452 5670";
        "country" = "nl";
        "street" = "Hogeweide 346";
        "state" = "Province of Utrecht";
        "city" = "Utrecht";
        "policy" = true;
        "hasAgreedToTerms" = true;
        "product" = "Desktop Video ${version} SDK";
      };

    } ''
    RESOLVEURL=$(curl \
      -s \
      -H "$USERAGENT" \
      -H 'Content-Type: application/json;charset=UTF-8' \
      -H "Referer: https://www.blackmagicdesign.com/support/download/$REFERID/Linux" \
      --data-ascii "$REQJSON" \
      --compressed \
      "$SITEURL")

    curl \
      --retry 3 --retry-delay 3 \
      --compressed \
      "$RESOLVEURL" \
      > $out
  '';

  unpackPhase = ''
    runHook preUnpack

    ${unzip}/bin/unzip $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -dr --no-preserve='ownership' "Blackmagic DeckLink SDK ${version}/Linux/include" $out/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.blackmagicdesign.com/support/family/capture-and-playback";
    maintainers = [ maintainers.hexchen ];
    license = licenses.unfree;
    description = "SDK for the Blackmagic Decklink series of capture and playback cards";
    platforms = platforms.linux;
  };
}
