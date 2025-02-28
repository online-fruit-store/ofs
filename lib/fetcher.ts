// Custom error class to handle fetch errors
export class FetchError extends Error {
  info: unknown;
  status: number;

  constructor(message: string, status?: number, info?: unknown) {
    super(message);
    this.info = info;
    this.status = status ?? 500;
    // Set the prototype explicitly to allow instanceof checks
    Object.setPrototypeOf(this, FetchError.prototype);
  }
}

/**
 * From SWR Docs
 *
 * A generic fetcher function for use with SWR.
 *
 * Fetches data from the provided URL and returns the parsed JSON response.
 * If the response is not OK (status code not in 200-299), it throws a `FetchError`
 * containing additional error information.
 *
 * @example
 * import useSWR from 'swr';
 *
 * const { rows } = useSWR<ItemsGetResponse>(`/api/items?${searchParams}`, fetcher);
 *
 * @example
 * async function getItems() {
 *   try {
 *     const data = await fetcher('/api/items');
 *     console.log('Fetched items:', data);
 *   } catch (error) {
 *     if (error instanceof FetchError) {
 *       console.error('Fetch failed:', error.status, error.info);
 *     }
 *   }
 * }
 */
const fetcher = async (input: RequestInfo | URL, init?: RequestInit) => {
  const res = await fetch(input, init);

  // Artificial timeout to see loading state
  // await new Promise((resolve) => setTimeout(resolve, 2000));

  // If the status code is not in the range 200-299,
  // we still try to parse and throw it.
  if (!res.ok) {
    const error = new FetchError("An error occurred while fetching the data.");
    // Attach extra info to the error object.
    error.info = await res.json();
    error.status = res.status;
    console.error(error);
    throw error;
  }

  const data = await res.json();

  return data;
};

export default fetcher;
