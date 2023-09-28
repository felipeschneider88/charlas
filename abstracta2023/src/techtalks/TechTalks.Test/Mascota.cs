using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Serializers;
using MongoDB.Driver;
using NUnit.Framework;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using TechTalks.Api.Controllers;
using TechTalks.Api.model;

namespace TechTalks.Test
{
    public class Mascotas
    {
        private MascotaController _controller;
        [SetUp]
        public void Setup()
        {
        }

        [Test]
        public void GetALl()
        {
            //Arrange
            _controller = new MascotaController();
            TestContext.Out.WriteLine("Vamos a crear una instancia del controlador");

            //Act
            TestContext.Out.WriteLine("Vamos a obtener la lista de mascostas");
            var result  =  _controller.get();
           

            //Assert
            TestContext.Out.WriteLine("Comprobamos si lo que nos devuelve es una lista de mascotas");
            Assert.IsInstanceOf(typeof(IEnumerable<MascotaDto>), result);

        }
        [Test]
        public void GetById_NotExists()
        {
            //Arrange
            _controller = new MascotaController();
            TestContext.Out.WriteLine("Vamos a crear una instancia del controlador");

            //Act
            TestContext.Out.WriteLine("Vamos a obtener una mascota con un ID que no existe");
            Guid auxID = Guid.NewGuid();
            var data = _controller.getByIdAsync(auxID);
            var response = data.Result as NotFoundObjectResult;

            //Assert

            TestContext.Out.WriteLine($"La respuesta fue: {response}");
            TestContext.Out.WriteLine($"El resultado de la tarea es: {response.StatusCode}");
            Assert.AreEqual((int)HttpStatusCode.NotFound, response.StatusCode);
        }

        [Test]
        public void GetById()
        {
            //Arrange
            TestContext.Out.WriteLine("Vamos a crear una instancia del controlador");
            _controller = new MascotaController();
            List<MascotaDto>  result =  _controller.get().ToList();

            //Act
            TestContext.Out.WriteLine("Vamos a obtener la mascota con el ID obtenido");
            Guid auxID = result[0].Id;
            var data = _controller.getByIdAsync(auxID);
            var response = data.Result as OkObjectResult;

            TestContext.Out.WriteLine($"La respuesta fue: {response}");
            //Assert
            TestContext.Out.WriteLine($"Comprobamos que el valor de respuesa es 200: {response.StatusCode}");
            Assert.IsInstanceOf(typeof(ActionResult<MascotaDto>), data);
            Assert.AreEqual((int)HttpStatusCode.OK, response.StatusCode);

        }

        [Test]
        public void postOne()
        {
            //Arrange
            _controller = new MascotaController();
            TestContext.Out.WriteLine("Vamos a crear una instancia del controlador");

            //Act
            TestContext.Out.WriteLine("Vamos a crear una mascota de prueba");
            CrateMascotaDto nuevaMascota = new CrateMascotaDto("otro", 1);
            var data = _controller.Post(nuevaMascota);
            var response = data.Result as CreatedAtActionResult;
            Mascota createdMascota = (Mascota) response.Value;
            TestContext.Out.WriteLine($"El resultado de la tarea es: {response}");
            Assert.AreEqual(nuevaMascota.Name, createdMascota.Name);
            Assert.AreEqual(nuevaMascota.Age, createdMascota.Age);

            TestContext.Out.WriteLine($"La respuesta fue: {response}");
            //Assert
            TestContext.Out.WriteLine($"Comprobamos que el valor de respuesa es 201: {response.StatusCode}");
            Assert.AreEqual((int)HttpStatusCode.Created, response.StatusCode);

        }

    }
}