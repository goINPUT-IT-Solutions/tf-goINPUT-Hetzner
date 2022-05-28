######################################################
#               _____ _   _ _____  _    _ _______    #
#              |_   _| \ | |  __ \| |  | |__   __|   #
#     __ _  ___  | | |  \| | |__) | |  | |  | |      #
#    / _` |/ _ \ | | | . ` |  ___/| |  | |  | |      #
#   | (_| | (_) || |_| |\  | |    | |__| |  | |      #
#    \__, |\___/_____|_| \_|_|     \____/   |_|      #
#     __/ |                                          #
#    |___/                                           #
#                                                    #
######################################################

data "cloudflare_zone" "goinput_de" {
  name = "goinput.de"
}

data "cloudflare_zone" "goitservers_com" {
  name = "goitservers.com"
}

data "cloudflare_zone" "goitcdn_com" {
  name = "goitcdn.com"
}

data "cloudflare_zone" "goitdns_com" {
  name = "goitdns.com"
}
