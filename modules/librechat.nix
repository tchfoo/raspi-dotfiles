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
      DOMAIN_CLIENT = "https://services.tchfoo.com/chat";
      DOMAIN_SERVER = "https://services.tchfoo.com/chat";
    };
    credentials = config.secrets.librechat;
    enableLocalDB = true;
    meilisearch.enable = true;
  };

  services.meilisearch.masterKeyFile = config.secrets.meilisearch.MASTER_KEY;

  services.nginx.virtualHosts."services.tchfoo.com".locations."/chat" = {
    proxyPass = "http://localhost:${toString config.services.librechat.env.PORT}";
    recommendedProxySettings = true;
  };
}
