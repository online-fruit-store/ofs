export enum OrderBy {
  PRICEASCENDING,
  PRICEDESCENDING,
}

export enum PageSize {
  TEN = "10",
  TWENTY = "20",
  FIFTY = "50",
  DEFAULT = TEN,
}

export enum FetchErrorStatusCodes {
  NOTFOUND = 404,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  BADREQUEST = 400,
  INTERNALSERVERERROR = 500,
}

export enum DefaultErrorMessages {
  NOTFOUND = "Resource not found",
  UNAUTHORIZED = "Unauthorized",
  FORBIDDEN = "Forbidden",
  BADREQUEST = "Bad request",
  INTERNALSERVERERROR = "Internal server error",
}
