type AoFetchOptions = {
    method?: "GET" | "POST";
    body?: Record<string, string | number | boolean>;
};
type AoFetchResponse = {
    status: number;
    data: any;
};
declare const aofetch: (location: string, options?: AoFetchOptions) => Promise<AoFetchResponse>;
export { aofetch };
