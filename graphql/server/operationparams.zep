namespace GraphQL\Server;

/**
 * Structure representing parsed HTTP parameters for GraphQL operation
 */
class OperationParams
{
    /**
     * Id of the query (when using persistent queries).
     *
     * Valid aliases (case-insensitive):
     * - id
     * - queryId
     * - documentId
     *
     * @api
     * @var string
     */
    public queryId;
    /**
     * @api
     * @var string
     */
    public query;
    /**
     * @api
     * @var string
     */
    public operation;
    /**
     * @api
     * @var array
     */
    public variables;
    /**
     * @var array
     */
    protected originalInput;
    /**
     * @var bool
     */
    protected readOnly;
    /**
     * Creates an instance from given array
     *
     * @api
     * @param array $params
     * @param bool $readonly
     * @return OperationParams
     */
    public static function create(array params, bool readonly = false) -> <OperationParams>
    {
        var instance, tmp;
    
        let instance =  new static();
        let params =  array_change_key_case(params, CASE_LOWER);
        let instance->originalInput = params;
        let params = this->array_plus(params, ["query" : null, "queryid" : null, "documentid" : null, "id" : null, "operationname" : null, "variables" : null]);
        if params["variables"] === "" {
            let params["variables"] = null;
        }
        if is_string(params["variables"]) {
            let tmp =  json_decode(params["variables"], true);
            if !(json_last_error()) {
                let params["variables"] = tmp;
            }
        }
        let instance->query = params["query"];
        let instance->queryId =   params["queryid"] ? params["queryid"] : params["documentid"] ?  params["queryid"] ? params["queryid"] : params["documentid"] : params["id"];
        let instance->operation = params["operationname"];
        let instance->variables = params["variables"];
        let instance->readOnly =  (bool) readonly;
        return instance;
    }
    
    /**
     * @api
     * @param string $key
     * @return mixed
     */
    public function getOriginalInput(string key)
    {
        return  isset this->originalInput[key] ? this->originalInput[key]  : null;
    }
    
    /**
     * Indicates that operation is executed in read-only context
     * (e.g. via HTTP GET request)
     *
     * @api
     * @return bool
     */
    public function isReadOnly() -> bool
    {
        return this->readOnly;
    }

    private function array_plus(array1, array2)
    {
        var union, key, value;
        let union = array1;
        for key, value in array2 {
            if false === array_key_exists(key, union) {
                let union[key] = value;
            }
        }
        
        return union;
    }
}