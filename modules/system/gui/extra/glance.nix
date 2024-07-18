{ pkgs, lib, config, ... }:

{
  services.glance = {
    enable = true;
    settings = {
      server.port = 5678;
      pages = [{
        name = "Home";
        #FIXME: theme dont work
        theme = {
          background-color = "240 21 15";
          contrast-multiplier = 1.2;
          primary-color = "217 92 83";
          positive-color = "115 54 76";
          negative-color = "347 70 65";
        };
        columns = [
          {
            size = "small";
            widgets = [
              { type = "calendar"; }
              {
                type = "rss";
                limit = 10;
                collapse-after = 3;
                cache = "3h";
                #TODO: replace with my feeds
                feeds = [
                  { url = "https://ciechanow.ski/atom.xml"; }
                  {
                    url = "https://www.joshwcomeau.com/rss.xml";
                    title = "Josh Comeau";
                  }
                  { url = "https://samwho.dev/rss.xml"; }
                  { url = "https://awesomekling.github.io/feed.xml"; }
                  {
                    url = "https://ishadeed.com/feed.xml";
                    title = "Ahmad Shadeed";
                  }
                ];
              }
              {
                type = "twitch-channels";
                channels =
                  [ "theprimeagen" "christitustech" "otplol_" "caedrel" ];
              }
            ];
          }
          {
            size = "full";
            widgets = [
              { type = "hacker-news"; }
              {
                type = "videos";
                channels = [
                  "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                  "UCBJycsmduvYEL83R_U4JriQ" # MKBHD
                  "UCsnGwSIHyoYN0kiINAGUKxg" # WolfgangsChannel
                  "UCv6J_jJa8GJqFwQNgNrMuww" # ServeTheHome
                  "UCOk-gHyjcWZNj3Br4oxwh0A" # Techno Tim
                  "UCbRP3c757lWg9M-U7TyEkXA" # THEO
                  "UCIgNWXsJcFwvFptmUic6wSw" # apalrdsadventures
                  "UCUyeluBRhGPCW4rPe_UvBZQ" # The primeagen
                ];
              }
              {
                type = "reddit";
                subreddit = "neovim";
              }
              {
                type = "reddit";
                subreddit = "unixporn";
              }
              {
                type = "reddit";
                subreddit = "olkb";
              }
              {
                type = "reddit";
                subreddit = "vim";
              }
              {
                type = "reddit";
                subreddit = "selfhosted";
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "weather";
                location = "Limoges, France";
              }
              {
                type = "markets";
                markets = [
                  {
                    symbol = "SPY";
                    name = "S&P 500";
                  }
                  {
                    symbol = "CAC40";
                    name = "CAC 40";
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
                  {
                    symbol = "GOOGL";
                    name = "Google";
                  }
                  {
                    symbol = "AMD";
                    name = "AMD";
                  }
                ];
              }
            ];
          }
        ];
      }];
    };
  };
}

