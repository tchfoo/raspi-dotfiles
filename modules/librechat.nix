{
  config,
  ...
}:

{
  services.librechat = {
    enable = true;
    credentials = {
      CREDS_KEY = config.age.secrets.librechat-creds-key.path;
      CREDS_IV = config.age.secrets.librechat-creds-iv.path;
      JWT_SECRET = config.age.secrets.librechat-jwt-secret.path;
      JWT_REFRESH_SECRET = config.age.secrets.librechat-jwt-refresh-secret.path;
    };
    env = {
      ALLOW_REGISTRATION = true;
      OPENAI_API_KEY = "user_provided";
      GOOGLE_KEY = "user_provided";
      ANTHROPIC_API_KEY = "user_provided";
    };
    enableLocalDB = true;
  };

  services.nginx.virtualHosts."test.tchfoo.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.librechat.env.PORT}";
      recommendedProxySettings = true;
    };
  };
}
