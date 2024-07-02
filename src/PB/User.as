class User
{
    string Id;
    string Name;

    User(CGamePlayerInfo@ user)
    {
        Id = user.WebServicesUserId;
        Name = user.Name;
    }
}
