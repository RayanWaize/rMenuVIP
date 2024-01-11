Config = {
    newEsx = false, -- Vous utiliez la nouvelle version legeacy (Nouvelle declaration) [ESX = exports["es_extended"]:getSharedObject()]
    nameServer = "rDev", -- Le nom de votre serveur ?
    openWithKeyboard = true, -- Ouvrir le menu avec une touche (F3)
    openWithCommand = false, -- Ouvrir le menu avec une commande (menuvip)
    levelVIP = { -- Les niveau VIPs
        [1] = "Bronze",
        [2] = "Or",
        [3] = "Diamant"
    },
    accessForVIP = { -- Les accès au diffèrent menu selon le Level du VIP
        menuPed = 2,
        menuWeapon = 3,
        menuCar = 1,
        menuProps = 3
    },


    ---- Config options VIP ----

    -- Category Car
    plateColor = {
        {label = "Yankton", indexColor = 5},
        {label = "Bleu/Blanc", indexColor = 0},
        {label = "Bleu/Blanc 2", indexColor = 3},
        {label = "Bleu/Blanc 3", indexColor = 4},
        {label = "Jaune/Bleu", indexColor = 2},
        {label = "Jaune/Noir", indexColor = 1},
    },
    xenonColor = {
        {label = "Par défaut", indexColor = -1},
        {label = "Blanc", indexColor = 0},
        {label = "Bleu", indexColor = 1},
        {label = "Bleu électrique", indexColor = 2},
        {label = "Vert menthe", indexColor = 3},
        {label = "Vert citron", indexColor = 4},
        {label = "Jaune", indexColor = 5},
        {label = "Golden Shower", indexColor = 6},
        {label = "Orange", indexColor = 7},
        {label = "Rouge", indexColor = 8},
        {label = "Rose poney", indexColor = 9},
        {label = "Rose vif", indexColor = 10},
        {label = "Violet", indexColor = 11},
        {label = "Lumière noire", indexColor = 12},
    },
    windowColor = {
        {label = "Aucune teinte", indexColor = 0},
        {label = "Noir pur", indexColor = 1},
        {label = "Fumée foncée", indexColor = 2},
        {label = "Fumée légère", indexColor = 3},
        {label = "Pas de vitres", indexColor = 4},
        {label = "Teinte limousine", indexColor = 5},
        {label = "Vert", indexColor = 6},
    },

    -- Category Peds
    allPeds = {
        {label = "Prisonnier", modelPed = "u_m_y_prisoner_01"},
    },

    -- Category Weapons
    tintWeapon = {
        {label = "Aucune teinte", indexColor = 0},
        {label = "Vert", indexColor = 1},
        {label = "Or", indexColor = 2},
        {label = "Rose", indexColor = 3},
        {label = "Armée", indexColor = 4},
        {label = "LSPD", indexColor = 5},
        {label = "Orange", indexColor = 6},
        {label = "Platine", indexColor = 7},
    },

    -- Category Props
    allProps = {
        {label = "Cone", modelProps = "prop_roadcone02a"},
        {label = "Barrière", modelProps = "prop_barrier_work05"},
    },

    -- Reward Settings
    timeRefreshReward = 60000 * 1, -- Tout les combien de temps actuellement 1H
    allReward = {
        --[[
            name = Nom de l'item pour cash pas d'importance.
            amount = Combien donner argent ou items ?
            notification = La notification envoyer avec la récompense.
        ]]--
        {name = "cash", amount = 500, type = "cash", notification = "Vous venez de gagner 500$"},
        {name = "pain", amount = 10, type = "item", notification = "Vous venez de gagner 10 pains"},
        {name = "eau", amount = 10, type = "item", notification = "Vous venez de gagner 10 bouteille d'eau"},
    }
}