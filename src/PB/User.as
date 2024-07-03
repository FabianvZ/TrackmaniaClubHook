class User
{
    string Id;
    string Name;
    int PinnedClub;

    User(CGamePlayerInfo@ user)
    {
        Id = user.WebServicesUserId;
        Name = user.Name;
        PinnedClub = GetPinnedClub();
    }

    private int GetPinnedClub() {
        Log("Getting club");
        auto info = Nadeo::LiveServiceRequest("/api/token/club/player/info");

        int pinnedClubId = info["pinnedClub"];
        Log("Clubid is: " + pinnedClubId);

        return pinnedClubId;
    }

}