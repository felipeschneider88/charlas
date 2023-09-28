--Testing this https://postgrest.org/en/stable/tutorials/tut1.html
-- DB and schema
CREATE DATABASE demo;


create schema api;
-- CreateTable
CREATE TABLE api.users (
    id serial PRIMARY KEY,
    username text,
    name text,
    email text,
    password text,
    created TIMESTAMP NOT NULL DEFAULT now()
);

-- CreateIndex
CREATE UNIQUE INDEX users_email_unique ON api.users(email);


-- CreateTable
CREATE TABLE api.mascota (
    id serial PRIMARY KEY,
    name text NOT NULL,
    description text,
    type text NOT NULL,
    avatar text,
    userId int
);

ALTER TABLE api.mascota 
    ADD FOREIGN KEY (userId) REFERENCES api.users(id)
;


create role web_anon nologin;

grant usage on schema api to web_anon;
grant select on api.users to web_anon;
grant select on api.mascota to web_anon;


create role authenticator noinherit login password 'mysecretpassword';
grant web_anon to authenticator;


grant select on api.users to authenticator;
grant select on api.mascota to authenticator;



INSERT INTO api.users (
    username ,
    name ,
    email ,
    password 
)
VALUES(
    'felipe', 
    'felipe schneider', 
    'felipe@adn.edu.uy', 
    'passw0rd'
);

INSERT INTO api.users (
    username ,
    name ,
    email ,
    password
    avatar
)
VALUES(
    'Miguel', 
    'miguel Ruiz', 
    'toosl@adn.edu.uy', 
    'passw0rd'
);


INSERT INTO api.users (
    username ,
    name ,
    email ,
    password 
)
VALUES(
    'Ilda', 
    'Ilda Gomez', 
    'finance@adn.edu.uy', 
    'passw0rd'
);

INSERT INTO api.mascota (
    name ,
    description ,
    type ,
    avatar ,
    userId
)
VALUES(
    'Garfield', 
    'Gato atigrado anaranjado obsesionado con la lasagna ', 
    'gato', 'https://media.licdn.com/dms/image/C4E03AQFJvFLBLepc3Q/profile-displayphoto-shrink_400_400/0/1552061656651?e=1696464000&v=beta&t=8pVljC3pLy0wb9VJyD4oPjKIsGLhYdJ6YSDrrkZiIMk',
	1
);

INSERT INTO api.mascota (
    name ,
    description ,
    type ,
    avatar ,
    userId
)
VALUES(
    'Firulaif', 
    'Perro coker', 
    'perro', 'https://www.mexicodesconocido.com.mx/wp-content/uploads/2021/03/Depositphotos_298171042_l-2015.jpg',
	1
);

INSERT INTO api.mascota (
    name ,
    description ,
    type ,
    avatar ,
    userId
)
VALUES(
    'lassie', 
    'Perro Collie', 
    'perro', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Pal_as_Lassie_1942.JPG/300px-Pal_as_Lassie_1942.JPG',
	2
);

INSERT INTO api.mascota (
    name ,
    description ,
    type ,
    avatar ,
    userId
)
VALUES(
    'tanque', 
    'Doberman', 
    'perro', 'https://images.unsplash.com/photo-1536677412572-c277de11e458?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZG9iZXJtYW4lMjBwaW5zY2hlcnxlbnwwfHwwfHx8MA%3D%3D&w=1000&q=80',
	3
);


create view api.listamascotas as
SELECT m.name as NombreMascota, m.avatar, m.type, u.name as nombreCliente, u.id as userid
  FROM api.mascota as m
  inner join api.users as u on  u.id=m.userid
  
 
grant select on api.listamascotas to web_anon;

--Mayor que 1
--http://localhost:3000/listamascotas?userid=gt.1 

--type es perro y el userid es 1
--http://localhost:3000/listamascotas?userid=eq.1&type=eq.perro

--INNER JOIN N a 1
--http://localhost:3000/users?select=username,mascota(name, type,avatar)


------------------------------------------------------------------------------------
-- Funciones 
CREATE FUNCTION api.suma_entera(a integer, b integer)
RETURNS integer AS $$
 SELECT a + b;
$$ LANGUAGE SQL IMMUTABLE;

select api.suma_entera(1,1)


--Llamar a la funcion
--http://localhost:3000/rpc/suma_entera