{
  config,
  ...
}:

let
  secrets = config.sops.secrets;
in
{
  services.glance = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.secrets."glance/ENVIRONMENT_FILE".path;
    settings = {
      server = {
        port = 11146;
        base-url = "/glance";
        proxied = true;
      };
      auth = {
        secret-key._secret = secrets."glance/SECRET_KEY".path;
        users = {
          ymstnt = {
            password._secret = secrets."glance/USER_YMSTNT_PASSWORD".path;
          };
        };
      };
      theme = {
        primary-color = "200 100 60";
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "group";
                  widgets = [
                    {
                      type = "calendar";
                      first-day-of-week = "monday";
                    }
                    {
                      type = "clock";
                      hour-format = "24h";
                      timezones = [
                        {
                          timezone = "Etc/UTC";
                          label = "UTC/GMT";
                        }
                        {
                          timezone = "EST5EDT";
                          label = "EST/EDT";
                        }
                        {
                          timezone = "GB";
                          label = "GMT/BST";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "custom-api";
                  title = "Current week (uni)";
                  cache = "12h";
                  url = "https://uwc.ymstnt.com/uwc?days-left-exam&days-left-break&append-week";
                  template = ''
                    <p class="color-paragraph">{{ .JSON.String "message" }}</p>
                  '';
                }
                {
                  type = "twitch-channels";
                  hide-header = true;
                  collapse-after = 3;
                  sort-by = "live";
                  channels = [
                    "sfgameofficial"
                    "xisumavoid"
                    "impulsesv"
                    "minecraft"
                    "Reden1471"
                    "skizzleman"
                    "tangotek"
                    "lukacs00"
                    "alexovics"
                    "cosmoyaha"
                    "jollywangcore"
                    "cubfan135"
                    "illeskristof_"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "kagi";
                  hide-header = true;
                  new-tab = true;
                  bangs = [
                    {
                      title = "nixpkgs";
                      shortcut = "!nixpkgs";
                      url = "https://search.nixos.org/packages?query={QUERY}";
                    }
                    {
                      title = "NixOS Options";
                      shortcut = "!nixopt";
                      url = "https://search.nixos.org/options?query={QUERY}";
                    }
                    {
                      title = "nixpkgs update tracker";
                      shortcut = "!nixu";
                      url = "https://nixpkgs-tracker.ocfox.me/?pr={QUERY}";
                    }
                    {
                      title = "Google";
                      shortcut = "!g";
                      url = "https://google.com/q={QUERY}";
                    }
                    {
                      title = "GitHub Repositories";
                      shortcut = "!ghr";
                      url = "https://github.com/search?q={QUERY}&type=repositories";
                    }
                    {
                      title = "GitHub Code Search";
                      shortcut = "!ghc";
                      url = "https://github.com/search?&q={QUERY}&type=code";
                    }
                    {
                      title = "GitHub Users";
                      shortcut = "!ghu";
                      url = "https://github.com/search?&q={QUERY}&type=users";
                    }
                    {
                      title = "GitHub Issues";
                      shortcut = "!ghi";
                      url = "https://github.com/search?&q={QUERY}&type=issues";
                    }
                    {
                      title = "GitHub Commit Search";
                      shortcut = "!ghcom";
                      url = "https://github.com/search?&q={QUERY}&type=commits";
                    }
                    {
                      title = "GitHub Packages";
                      shortcut = "!ghpkg";
                      url = "https://github.com/search?&q={QUERY}&type=registrypackages";
                    }
                    {
                      title = "GitHub Pull Requests";
                      shortcut = "!ghpr";
                      url = "https://github.com/search?&q={QUERY}&type=pullrequests";
                    }
                    {
                      title = "GitHub Discussions";
                      shortcut = "!ghd";
                      url = "https://github.com/search?&q={QUERY}&type=discussions";
                    }
                  ];
                }
                {
                  type = "custom-api";
                  title = "Miniflux";
                  hide-header = true;
                  url = "https://services.tchfoo.com/miniflux/v1/entries?limit=10&order=published_at&direction=desc&status=unread";
                  headers = {
                    X-Auth-Token._secret = secrets."glance/MINIFLUX_TOKEN".path;
                    Accept = "application/json";
                  };
                  template = ''
                    <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                      {{ range .JSON.Array "entries" }}
                        <li>
                            <div class="flex gap-10 row-reverse-on-mobile thumbnail-parent">
                                <div class="grow min-width-0">
                                    <a href="https://services.tchfoo.com/miniflux/unread/entry/{{ .String "id" }}" class="size-title-dynamic color-primary-if-not-visited" target="_blank" rel="noreferrer">{{ .String "title" }}</a>
                                    <ul class="list-horizontal-text flex-nowrap text-compact">
                                        <li class="shrink-0">{{ .String "feed.title" }}</li>
                                        <li class="shrink-0" {{ .String "published_at" | parseTime "rfc3339" | toRelativeTime }}></li>
                                        <li class="min-width-0"><a class="visited-indicator text-truncate block" href="{{ .String "url" | safeURL }}" target="_blank" rel="noreferrer" title="Link">Link</a></li>
                                    </ul>
                                </div>
                            </div>
                        </li>
                      {{ else }}
                        <p class="color-paragraph">There are no unread entries.</p>
                      {{ end }}
                    </ul>
                  '';
                }
                {
                  type = "split-column";
                  widgets = [
                    {
                      type = "bookmarks";
                      hide-header = true;
                      groups = [
                        {
                          title = "Tchfoo & co.";
                          links = [
                            {
                              title = "gepDrive";
                              url = "https://gd.tchfoo.com";
                            }
                            {
                              title = "ymstnt";
                              url = "https://ymstnt.com";
                            }
                            {
                              title = "Tchfoo Services Status";
                              url = "https://status.tchfoo.com";
                            }
                          ];
                        }
                        {
                          title = "Egyetem";
                          links = [
                            {
                              title = "Neptun";
                              url = "https://neptun.uni-obuda.hu/ujhallgato";
                            }
                            {
                              title = "Moodle";
                              url = "https://main.elearning.uni-obuda.hu/";
                            }
                            {
                              title = "K-MOOC";
                              url = "https://www.kmooc.uni-obuda.hu/";
                            }
                            {
                              title = "OPEN e-learning";
                              url = "https://open.elearning.uni-obuda.hu/";
                            }
                            {
                              title = "ÓE Weboldal";
                              url = "https://uni-obuda.hu/";
                            }
                            {
                              title = "NIK Weboldal";
                              url = "https://nik.uni-obuda.hu/";
                            }
                            {
                              title = "Telefonkönyv";
                              url = "https://uni-obuda.hu/telefonkonyv/";
                            }
                            {
                              title = "Tanév rendje";
                              url = "https://uni-obuda.hu/tanev-rendje/";
                            }
                            {
                              title = "NIKHÖK";
                              url = "https://nikhok.hu";
                            }
                          ];
                        }
                      ];
                    }
                    {
                      type = "monitor";
                      hide-header = true;
                      cache = "5m";
                      title = "Services";
                      sites = [
                        {
                          title = "gepDrive";
                          url = "https://gd.tchfoo.com";
                          icon = "mdi:harddisk";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "ymstnt.com";
                          url = "https://ymstnt.com";
                          icon = "https://raw.githubusercontent.com/ymstnt/website/refs/heads/main/static/android-chrome-512x512.png";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "Miniflux";
                          url = "https://services.tchfoo.com/miniflux";
                          icon = "auto-invert di:miniflux";
                          error-url = "https://status.tchfoo.com";
                        }
                        {
                          title = "PocketID";
                          url = "https://auth.tchfoo.com";
                          icon = "auto-invert di:pocket-id";
                          error-url = "https://status.tchfoo.com";
                        }
                      ];
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
                  hide-header = true;
                  location._secret = secrets."glance/WEATHER_LOCATION".path;
                  units = "metric";
                  hour-format = "24h";
                  hide-location = true;
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "custom-api";
                      title = "Android";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_ANDROID}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_ANDROID}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key._secret = secrets."glance/NEXTDNS_API_KEY".path;
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "Windows";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_WINDOWS}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_WINDOWS}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key._secret = secrets."glance/NEXTDNS_API_KEY".path;
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "TV";
                      title-url = "https://my.nextdns.io/\${NEXTDNS_ID_TV}";
                      cache = "1h";
                      url = "https://api.nextdns.io/profiles/\${NEXTDNS_ID_TV}/analytics/status?from=-1M";
                      headers = {
                        X-Api-Key._secret = secrets."glance/NEXTDNS_API_KEY".path;
                      };
                      template = ''
                        {{ if eq .Response.StatusCode 200 }}
                          <div style="display: flex; justify-content: space-between;">
                            {{ $total := 0.0 }}
                            {{ $blocked := 0.0 }}
                            {{ range .JSON.Array "data" }}
                              {{ $total = add $total (.Int "queries" | toFloat) }}
                              {{ if eq (.String "status") "blocked" }}
                                {{ $blocked = add $blocked (.Int "queries" | toFloat) }}
                              {{ end }}
                            {{ end }}
                            <div style="flex: 1; text-align: center;">
                              <p>Queries</p>
                              <p>{{ printf "%.0f" $total }}</p>
                            </div>
                            <div style="flex: 1; text-align: center; color: var(--color-negative);">
                              <p>Blocked</p>
                              <p>{{ printf "%.0f" $blocked }}</p>
                            </div>
                            <div style="flex: 1; text-align: center;">
                              <p>Block Rate</p>
                              {{ if gt $total 0.0 }}
                                <p>{{ div (mul $blocked 100) $total | printf "%.2f" }}%</p>
                              {{ else }}
                                <p>0.00%</p>
                              {{ end }}
                            </div>
                          </div>
                        {{ else }}
                          <div style="text-align: center; color: var(--color-negative);">
                            Error: {{ .Response.StatusCode }} - {{ .Response.Status }}
                          </div>
                        {{ end }}
                      '';
                    }
                  ];
                }
                {
                  type = "releases";
                  hide-header = true;
                  cache = "12h";
                  show-source-icon = true;
                  collapse-after = 3;
                  token._secret = secrets."glance/GH_TOKEN".path;
                  repositories = [
                    "backuppc/backuppc"
                    "Beaver-Notes/Beaver-Notes"
                    "bewcloud/bewcloud"
                    "bwmarrin/discordgo"
                    "charmbracelet/soft-serve"
                    "diamondburned/dissent"
                    "dynamyc010/npu"
                    "emacs-mirror/emacs"
                    "FilenCloudDienste/filen-desktop"
                    "FilenCloudDienste/filen-mobile"
                    "florisboard/florisboard"
                    "GetPublii/Publii"
                    "getzola/zola"
                    "glanceapp/glance"
                    "go-vikunja/vikunja"
                    "helix-editor/helix"
                    "jellyfin/jellyfin"
                    "MCCTeam/Minecraft-Console-Client"
                    "memorysafety/river"
                    "microsoft/edit"
                    "minecraft-linux/mcpelauncher-manifest"
                    "miniflux/v2"
                    "neptun-extension-project/nep"
                    "NixOS/nix"
                    "pocket-id/pocket-id"
                    "privacyguides/privacyguides.org"
                    "RikkaApps/Shizuku"
                    "silverbulletmd/silverbullet"
                    "superseriousbusiness/gotosocial"
                    "tauraamui/lilly"
                    "TryQuiet/quiet"
                    "tutao/tutanota"
                    "UnlegitSenpaii/FAE_Linux"
                    "upptime/uptime-monitor"
                    "wavetermdev/waveterm"
                    "webosbrew/webos-homebrew-channel"
                    "webosbrew/youtube-webos"
                    "wezterm/wezterm"
                    "zed-industries/zed"
                    "zyedidia/micro"
                  ];
                }
                {
                  type = "markets";
                  hide-header = true;
                  markets = [
                    {
                      symbol = "EURHUF=X";
                      name = "EUR";
                    }
                    {
                      symbol = "HUF=X";
                      name = "USD";
                    }
                    {
                      symbol = "GBPHUF=X";
                      name = "GBP";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Repositories";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  widgets = [
                    {
                      type = "repository";
                      hide-header = true;
                      repository = "tchfoo/raspi-dotfiles";
                      token._secret = secrets."glance/GH_TOKEN".path;
                      pull-requests-limit = -1;
                      issues-limit = -1;
                      commits-limit = 5;
                    }
                    {
                      type = "repository";
                      hide-header = true;
                      repository = "NixOS/nixpkgs";
                      token._secret = secrets."glance/GH_TOKEN".path;
                      pull-requests-limit = 5;
                      issues-limit = 5;
                      commits-limit = 5;
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."services.tchfoo.com".locations."/glance" = {
    proxyPass = "http://${config.services.glance.settings.server.host}:${toString config.services.glance.settings.server.port}";
    recommendedProxySettings = true;
    extraConfig = ''
      rewrite ^/glance/(.*)$ /$1? break;
    '';
 };
}
