create table if not exists book (
  key serial primary key,
  isbn text,
  title text,
  description text,
  author text,
  deleted boolean
);

create table if not exists readlist (
  key serial primary key,
  owner int references users(key),
  title text,
  createdtime timestamp not null default now(),
  deleted boolean
);

create table if not exists read (
  key serial primary key,
  owner int references users(key),
  list int references readlist(key),
  book int references book(key),
  isbn text,
  date timestamp not null default now(),
  createdtime timestamp not null default now(),
  deleted boolean
);
