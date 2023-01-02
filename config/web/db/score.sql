create table score (
  key serial primary key,
  slug text,
  owner int references users(key),
  correct int,
  wrong int,
  elapsed float,
  detail jsonb
);
