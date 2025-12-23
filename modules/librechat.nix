{
  config,
  ...
}:

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
    credentials = config.secrets.librechat;
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
