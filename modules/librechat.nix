{
  config,
  ...
}:

let
  secrets = config.sops.secrets;
in
{
  services.librechat = {
    enable = true;
    env = {
      ALLOW_REGISTRATION = true;
      OPENAI_API_KEY = "user_provided";
      GOOGLE_KEY = "user_provided";
      ANTHROPIC_API_KEY = "user_provided";
      BAN_VIOLATIONS = false;
    };
    credentials = {
      CREDS_KEY = secrets."librechat/CREDS_KEY".path;
      CREDS_IV = secrets."librechat/CREDS_IV".path;
      JWT_SECRET = secrets."librechat/JWT_SECRET".path;
      JWT_REFRESH_SECRET = secrets."librechat/JWT_REFRESH_SECRET".path;
    };
    enableLocalDB = true;
  };

  services.nginx.virtualHosts."chat.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.librechat.env.PORT}";
      recommendedProxySettings = true;
    };
  };
}
