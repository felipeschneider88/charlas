using System.ComponentModel.DataAnnotations;

namespace TechTalks.Api.model
{
    public record MascotaDto(Guid Id, string Name, int Age, DateTimeOffset CreatedTime);

    public record CrateMascotaDto([Required]string Name, [Range(0,100)] int Age);

    public record UpdateMascotaDto([Required] string Name, [Range(0, 100)] int Age);

}
