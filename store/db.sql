SET TIME ZONE 'UTC';

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS verification_token, accounts, sessions, users, admin, customer, address, "customerAddress", "paymentMethod", category, item, "customerOrder", "orderItem", delivery, discount, sale, coupon, transaction CASCADE;

-- Tables for NextAuth Postgres Adapter
CREATE TABLE verification_token
(
  identifier TEXT NOT NULL,
  expires TIMESTAMPTZ NOT NULL,
  token TEXT NOT NULL,
  PRIMARY KEY (identifier, token)
);

CREATE TABLE accounts
(
  id SERIAL,
  "userId" INTEGER NOT NULL,
  type VARCHAR(255) NOT NULL,
  provider VARCHAR(255) NOT NULL,
  "providerAccountId" VARCHAR(255) NOT NULL,
  refresh_token TEXT,
  access_token TEXT,
  expires_at BIGINT,
  id_token TEXT,
  scope TEXT,
  session_state TEXT,
  token_type TEXT,
  PRIMARY KEY (id)
);

CREATE TABLE sessions
(
  id SERIAL,
  "userId" INTEGER NOT NULL,
  expires TIMESTAMPTZ NOT NULL,
  "sessionToken" VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE users
(
  id SERIAL,
  name VARCHAR(255),
  email VARCHAR(255),
  image TEXT,
  "emailVerified" TIMESTAMPTZ,
  register_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Custom Tables

CREATE TABLE admin
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "userId" INTEGER NOT NULL,
  FOREIGN KEY ("userId") REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE customer
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "userId" INTEGER NOT NULL,
  FOREIGN KEY ("userId") REFERENCES users(id) ON DELETE CASCADE,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE address
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  street VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  zip VARCHAR(255) NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE "customerAddress"
(
  "customerId" UUID NOT NULL,
  "addressId" UUID NOT NULL,
  PRIMARY KEY ("customerId", "addressId"),
  FOREIGN KEY ("customerId") REFERENCES customer(id) ON DELETE CASCADE,
  FOREIGN KEY ("addressId") REFERENCES address(id) ON DELETE CASCADE
);

CREATE TABLE "paymentMethod"
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "customerId" UUID NOT NULL,
  "billingAddressId" UUID NOT NULL,
  "encryptedCardNumber" TEXT NOT NULL,
  "expiresAt" TIMESTAMPTZ NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE category
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE item
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "categoryId" UUID,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  "priceCents" INT NOT NULL,
  "weightLbs" INT,
  count INT NOT NULL,
  "imgSrc" TEXT,
  FOREIGN KEY ("categoryId") REFERENCES category(id) ON DELETE CASCADE,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE discount
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  amount INT NOT NULL,
  "fromDate" TIMESTAMPTZ,
  "toDate" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sale
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "discountId" UUID NOT NULL,
  "itemId" UUID,
  "categoryId" UUID,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY ("discountId") REFERENCES discount(id) ON DELETE CASCADE,
  FOREIGN KEY ("itemId") REFERENCES item(id) ON DELETE SET NULL,
  FOREIGN KEY ("categoryId") REFERENCES category(id) ON DELETE SET NULL
);

CREATE TABLE coupon
(
  code VARCHAR(255) PRIMARY KEY NOT NULL,
  "discountId" UUID NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY ("discountId") REFERENCES discount(id) ON DELETE CASCADE
);

CREATE TYPE "orderStatus" AS ENUM ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELED');

CREATE TABLE "customerOrder"
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "customerId" UUID NOT NULL,
  "addressId" UUID,
  "couponCode" VARCHAR(255),
  subtotal INT NOT NULL DEFAULT 0,
  "deliveryFee" INT NOT NULL DEFAULT 0,
  tax INT NOT NULL DEFAULT 0,
  total INT NOT NULL DEFAULT 0,
  "weightLbs" INT NOT NULL DEFAULT 0,
  status "orderStatus" NOT NULL DEFAULT 'PENDING',
  "scheduledAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY ("customerId") REFERENCES customer(id) ON DELETE CASCADE,
  FOREIGN KEY ("addressId") REFERENCES address(id) ON DELETE SET NULL,
  FOREIGN KEY ("couponCode") REFERENCES coupon(code) ON DELETE SET NULL
);

-- We can create some kind of trigger for the
-- delivery table s.t. when the scheduledAt date
-- is reached, a new delivery is created using
-- pg_cron or something, but I'm too lazy to
-- figure out how to do that now ;(
--
-- Important clarification on the foreign key fields below:
-- The reason we don't cascade DELETE on addressId
-- and customerId is because we want to keep the
-- delivery record even if the address or customer
-- is deleted. What's the driver going to do when
-- they're on the way to deliver the package and
-- the customer deletes their account?
--
-- Plus, the customer should still recieve their
-- order even if they delete an address or their
-- account. This is why we also include the address
-- information in the delivery table.
--
-- An order can only be deleted on the admin side,
-- so we cascade DELETE on orderId as it is on the
-- admins discretion to delete an order.
CREATE TABLE delivery
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "addressId" UUID,
  "customerId" UUID,
  "orderId" UUID NOT NULL,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  zip VARCHAR(255) NOT NULL,
  "scheduledAt" TIMESTAMPTZ NOT NULL,
  "shippedAt" TIMESTAMPTZ,
  "deliveredAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY ("addressId") REFERENCES address(id) ON DELETE SET NULL,
  FOREIGN KEY ("customerId") REFERENCES customer(id) ON DELETE SET NULL,
  FOREIGN KEY ("orderId") REFERENCES "customerOrder"(id) ON DELETE CASCADE
);

CREATE TABLE "orderItem"
(
  "orderId" UUID NOT NULL,
  "itemId" UUID NOT NULL,
  count INT NOT NULL,
  "weightLbs" INT NOT NULL DEFAULT 0,
  "priceCents" INT NOT NULL DEFAULT 0,
  PRIMARY KEY ("orderId", "itemId"),
  FOREIGN KEY ("orderId") REFERENCES "customerOrder"(id) ON DELETE CASCADE,
  FOREIGN KEY ("itemId") REFERENCES item(id) ON DELETE CASCADE,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION "calculateOrderItemFields"()
RETURNS TRIGGER AS $$
DECLARE
  "itemRecord" RECORD;
BEGIN
  SELECT "weightLbs", "priceCents" INTO "itemRecord" FROM item WHERE id = NEW."itemId";
  NEW."weightLbs" := "itemRecord"."weightLbs" * NEW.count;
  NEW."priceCents" := "itemRecord"."priceCents" * NEW.count;
  NEW."updatedAt" := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "beforeOrderItemInsertOrUpdate"
BEFORE INSERT OR UPDATE ON "orderItem"
FOR EACH ROW
EXECUTE FUNCTION "calculateOrderItemFields"();

CREATE OR REPLACE FUNCTION "applyCouponIfValid"()
RETURNS TRIGGER AS $$
DECLARE
  "couponRecord" RECORD;
  "discountRecord" RECORD;
BEGIN
  IF NEW."couponCode" IS NOT NULL THEN
    SELECT * INTO "couponRecord" FROM coupon WHERE code = NEW."couponCode";
    IF "couponRecord" IS NULL THEN
      RAISE EXCEPTION 'Coupon code does not exist';
    END IF;
    SELECT * INTO "discountRecord" FROM discount WHERE id = "couponRecord"."discountId";
    IF "discountRecord" IS NULL THEN
      RAISE EXCEPTION 'Discount record does not exist';
    END IF;
    NEW.total := NEW.total - "discountRecord".amount;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "beforeOrderInsert"
BEFORE INSERT ON "customerOrder"
FOR EACH ROW
EXECUTE FUNCTION "applyCouponIfValid"();

-- TODO: Currently sales on items or categories are not implemented. Figure out how to do this in this function.
CREATE OR REPLACE FUNCTION "recalculateOrderFields"()
RETURNS TRIGGER AS $$
DECLARE
  "affectedOrderId" RECORD;
  "newWeightLbs" INT;
  "newSubtotal" INT;
  "newDeliveryFee" INT := 0;
  "newTax" INT := 500; -- Flat for now...
  "newTotal" INT;
BEGIN
  -- If the order is being created or updated, we use NEW. If it's being deleted, we use OLD.
  "affectedOrderId" := COALESCE(NEW."orderId", OLD."orderId");

  -- Sum all orderItem rows for the affected order
  SELECT COALESCE(SUM("weightLbs"), 0), COALESCE(SUM("priceCents"), 0)
  INTO "newWeightLbs", "newSubtotal"
  FROM "orderItem"
  WHERE "orderId" = "affectedOrderId";

  -- Add delivery fee if weight is over 20 lbs
  IF "newWeightLbs" > 20 THEN
    "newDeliveryFee" := 500;
  END IF;

  -- Get the current total of the order so it can be incremented
  SELECT total INTO "newTotal" FROM "customerOrder" WHERE id = "affectedOrderId";

  -- Increment the total
  "newTotal" := "newTotal" + ("newSubtotal" + "newDeliveryFee" + "newTax");

  -- Update the order with the new values
  UPDATE "customerOrder"
  SET "weightLbs" = "newWeightLbs",
      subtotal = "newSubtotal",
      "deliveryFee" = "newDeliveryFee",
      tax = "newTax",
      total = "newTotal",
      "updatedAt" = NOW()
  WHERE id = "affectedOrderId";

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "afterOrderItemChange"
AFTER INSERT OR UPDATE OR DELETE ON "orderItem"
FOR EACH ROW
EXECUTE FUNCTION "recalculateOrderFields"();

-- Transactions should be immutable, so we don't
-- cascade DELETE on any of the foreign keys.
CREATE TABLE transaction
(
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "customerId" UUID NOT NULL,
  "paymentMethodId" UUID NOT NULL,
  "orderId" UUID NOT NULL,
  amount INT NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY ("customerId") REFERENCES customer(id) ON DELETE NO ACTION,
  FOREIGN KEY ("paymentMethodId") REFERENCES "paymentMethod"(id) ON DELETE NO ACTION,
  FOREIGN KEY ("orderId") REFERENCES "customerOrder"(id) ON DELETE NO ACTION
);
