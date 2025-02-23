{ config, ... }:

{
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 11146;
        base-url = "https://ymstnt.com/glance";
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                  first-day-of-week = "monday";
                }
                {
                  type = "rss";
                  limit = 10;
                  collapse-after = 3;
                  cache = "12h";
                  feeds = [
                    {
                      url = "https://selfh.st/rss/";
                      title = "selfh.st";
                      limit = 4;
                    }
                    {
                      url = "https://ymstnt.dev/rss.xml";
                      title = "ymstnt";
                    }
                  ];
                }
                {
                  type = "twitch-channels";
                  channels = [
                    "cosmoyaha"
                    "xisumavoid"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "group";
                  widgets = [
                    {
                      type = "hacker-news";
                    }
                    {
                      type = "lobsters";
                    }
                  ];
                }
                {
                  type = "videos";
                  channels = [
                    "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                    "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                    "UCsBjURrPoezykLs9EqgamOA" # Fireship
                    "UCBJycsmduvYEL83R_U4JriQ" # Marques Brownlee
                  ];
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "technology";
                      show-thumbnails = true;
                    }
                    {
                      type = "reddit";
                      subreddit = "selfhosted";
                      show-thumbnails = true;
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Budapest, Hungary";
                  units = "metric";
                  hour-format = "24h";
                }
                {
                  type = "markets";
                  symbol-link-template = "https://www.tradingview.com/symbols/{SYMBOL}/news";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "BTC-USD";
                      name = "Bitcoin";
                    }
                    {
                      symbol = "NVDA";
                      name = "NVIDIA";
                    }
                    {
                      symbol = "AAPL";
                      name = "Apple";
                    }
                    {
                      symbol = "MSFT";
                      name = "Microsoft";
                    }
                  ];
                }
                {
                  type = "releases";
                  cache = "1d";
                  repositories = [
                    "glanceapp/glance"
                    "pocket-id/pocket-id"
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."ymstnt.com".locations = {
    "^~ /glance/" = {
      proxyPass = "https://${config.services.glance.settings.server.host}:${toString config.services.glance.settings.server.port}";
      recommendedProxySettings = true;
    };
  };
}
