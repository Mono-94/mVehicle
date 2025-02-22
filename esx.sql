alter table owned_vehicles
    add id int first;

alter table owned_vehicles
    add metadata longtext null;

alter table owned_vehicles
    add mileage int null;

alter table owned_vehicles
    add coords longtext null;

alter table owned_vehicles
    add `keys` longtext null;

alter table owned_vehicles
    add lastparking varchar(100) null;

create index owned_vehicles_id_index
    on owned_vehicles (id);

alter table owned_vehicles
    drop primary key;

alter table owned_vehicles
    add constraint owned_vehicles_pk
        primary key (id);

alter table owned_vehicles
    add constraint owned_vehicles_uk
        unique (plate);

alter table owned_vehicles
    modify id int auto_increment;
