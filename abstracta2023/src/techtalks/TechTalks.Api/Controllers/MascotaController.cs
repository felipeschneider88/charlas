using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TechTalks.Api.extensions;
using TechTalks.Api.model;

namespace TechTalks.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MascotaController : ControllerBase
    {
        private static readonly List<Mascota> mascotas = new()
        {
            new Mascota(Guid.NewGuid(), "Firulaif",5, DateTimeOffset.UtcNow),
            new Mascota(Guid.NewGuid(), "Lazie", 7, DateTimeOffset.UtcNow),
            new Mascota(Guid.NewGuid(), "Rex", 20, DateTimeOffset.UtcNow)
        };

        public MascotaController()
        {
        }
        [HttpGet]
        public IEnumerable<MascotaDto> get()
        {
            return mascotas.Select(item => item.AsDto());
        }

        [HttpGet("{id}")]
        public ActionResult<MascotaDto> getByIdAsync(Guid id)
        {
            var item = mascotas.Where(item => item.Id == id).SingleOrDefault();
            if (item == null)
                return NotFound($"No existe una mascota con el id {id}");
            else
                return Ok(item.AsDto());
        }

        [HttpPost]
        public ActionResult<MascotaDto> Post(CrateMascotaDto newMascota)
        {
            var item = new Mascota(Guid.NewGuid(), newMascota.Name, newMascota.Age, DateTimeOffset.Now);
            mascotas.Add(item);
            return CreatedAtAction(nameof(getByIdAsync), new {id = item.Id }, item);
        }


        [HttpPut("{id}")]
        public async Task<ActionResult<Mascota>> Put(Guid id, UpdateMascotaDto mascota)
        {

            var existingMascota = mascotas.Where(item => item.Id == id).SingleOrDefault();
            if (existingMascota == null)
                return NotFound();

            var index = mascotas.FindIndex(existingItem => existingItem.Id == id);

            existingMascota.Name = mascota.Name;
            existingMascota.Age = mascota.Age;
            mascotas[index]= existingMascota;

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(Guid id)
        {
            var existingMascota = mascotas.Where(item => item.Id == id).SingleOrDefault();
            if (existingMascota == null)
                return NotFound();
            var index = mascotas.FindIndex(existingItem => existingItem.Id == id);
            mascotas.RemoveAt(index);
            return NoContent();

        }
    }
}
