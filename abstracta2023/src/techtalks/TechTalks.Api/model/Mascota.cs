using System.ComponentModel.DataAnnotations;

namespace TechTalks.Api.model
{
    public class Mascota
    {
        public Guid Id { get; set; }
        [Required]
        public string Name { get; set; }
        [Range(0,100)]
        public int Age { get; set; }
        public DateTimeOffset CreatedDate { get; set; }

        public Mascota(Guid id, string name, int age, DateTimeOffset createdAt)
        {
            Id = id;
            Name = name;
            Age = age;
            CreatedDate = createdAt;
        }
    }
}
