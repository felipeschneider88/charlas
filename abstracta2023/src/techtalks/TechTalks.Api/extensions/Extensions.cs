using TechTalks.Api.model;

namespace TechTalks.Api.extensions
{
    public static class Extensions
    {
        public static MascotaDto AsDto(this Mascota mascota)
        {
            return new MascotaDto(mascota.Id, mascota.Name, mascota.Age, mascota.CreatedDate);
        }
    }
}
