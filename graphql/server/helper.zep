namespace GraphQL\Server;

use GraphQL\Error\Error;
use GraphQL\Error\FormattedError;
use GraphQL\Error\InvariantViolation;
use GraphQL\Executor\ExecutionResult;
use GraphQL\Executor\Executor;
use GraphQL\Executor\Promise\Adapter\SyncPromiseAdapter;
use GraphQL\Executor\Promise\Promise;
use GraphQL\Executor\Promise\PromiseAdapter;
use GraphQL\GraphQL;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\Parser;
use GraphQL\Utils\AST;
use GraphQL\Utils\Utils;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Message\StreamInterface;
/**
 * Contains functionality that could be re-used by various server implementations
 */
class Helper
{
    /**
     * Parses HTTP request using PHP globals and returns GraphQL OperationParams
     * contained in this request. For batched requests it returns an array of OperationParams.
     *
     * This function does not check validity of these params
     * (validation is performed separately in validateOperationParams() method).
     *
     * If $readRawBodyFn argument is not provided - will attempt to read raw request body
     * from `php://input` stream.
     *
     * Internally it normalizes input to $method, $bodyParams and $queryParams and
     * calls `parseRequestParams()` to produce actual return value.
     *
     * For PSR-7 request parsing use `parsePsrRequest()` instead.
     *
     * @api
     * @param callable|null $readRawBodyFn
     * @return OperationParams|OperationParams[]
     * @throws RequestError
     */
    public function parseHttpRequest(readRawBodyFn = null)
    {
        var method, bodyParams, urlParams, contentType, rawBody;
    
        let method =  isset _SERVER["REQUEST_METHOD"] ? _SERVER["REQUEST_METHOD"]  : null;
        let bodyParams =  [];
        let urlParams = _GET;
        if method === "POST" {
            let contentType =  isset _SERVER["CONTENT_TYPE"] ? _SERVER["CONTENT_TYPE"]  : null;
            if stripos(contentType, "application/graphql") !== false {
                let rawBody =  readRawBodyFn ? {readRawBodyFn}()  : this->readRawBody();
                let bodyParams =  ["query" :  rawBody ? rawBody : ""];
            } else {
                if stripos(contentType, "application/json") !== false {
                    let rawBody =  readRawBodyFn ? {readRawBodyFn}()  : this->readRawBody();
                    let bodyParams =  json_decode( rawBody ? rawBody : "", true);
                    if json_last_error() {
                        throw new RequestError("Could not parse JSON: " . json_last_error_msg());
                    }
                    if !(is_array(bodyParams)) {
                        throw new RequestError("GraphQL Server expects JSON object or array, but got " . Utils::printSafeJson(bodyParams));
                    }
                } else {
                    if stripos(contentType, "application/x-www-form-urlencoded") !== false {
                        let bodyParams = _POST;
                    } else {
                        if contentType === null {
                            throw new RequestError("Missing \"Content-Type\" header");
                        } else {
                            throw new RequestError("Unexpected content type: " . Utils::printSafeJson(contentType));
                        }
                    }
                }
            }
        }
        return this->parseRequestParams(method, bodyParams, urlParams);
    }
    
    /**
     * Parses normalized request params and returns instance of OperationParams
     * or array of OperationParams in case of batch operation.
     *
     * Returned value is a suitable input for `executeOperation` or `executeBatch` (if array)
     *
     * @api
     * @param string $method
     * @param array $bodyParams
     * @param array $queryParams
     * @return OperationParams|OperationParams[]
     * @throws RequestError
     */
    public function parseRequestParams(string method, array bodyParams, array queryParams)
    {
        var result, index, entry, op;
    
        if method === "GET" {
            let result =  OperationParams::create(queryParams, true);
        } else {
            if method === "POST" {
                if isset bodyParams[0] {
                    let result =  [];
                    for index, entry in bodyParams {
                        let op =  OperationParams::create(entry);
                        let result[] = op;
                    }
                } else {
                    let result =  OperationParams::create(bodyParams);
                }
            } else {
                throw new RequestError("HTTP Method \"" . method . "\" is not supported");
            }
        }
        return result;
    }
    
    /**
     * Checks validity of OperationParams extracted from HTTP request and returns an array of errors
     * if params are invalid (or empty array when params are valid)
     *
     * @api
     * @param OperationParams $params
     * @return Error[]
     */
    public function validateOperationParams(<OperationParams> params) -> array
    {
        var errors;
    
        let errors =  [];
        if !(params->query) && !(params->queryId) {
            let errors[] = new RequestError("GraphQL Request must include at least one of those two parameters: \"query\" or \"queryId\"");
        }
        if params->query && params->queryId {
            let errors[] = new RequestError("GraphQL Request parameters \"query\" and \"queryId\" are mutually exclusive");
        }
        if params->query !== null && (!(is_string(params->query)) || empty(params->query)) {
            let errors[] = new RequestError("GraphQL Request parameter \"query\" must be string, but got " . Utils::printSafeJson(params->query));
        }
        if params->queryId !== null && (!(is_string(params->queryId)) || empty(params->queryId)) {
            let errors[] = new RequestError("GraphQL Request parameter \"queryId\" must be string, but got " . Utils::printSafeJson(params->queryId));
        }
        if params->operation !== null && (!(is_string(params->operation)) || empty(params->operation)) {
            let errors[] = new RequestError("GraphQL Request parameter \"operation\" must be string, but got " . Utils::printSafeJson(params->operation));
        }
        if params->variables !== null && (!(is_array(params->variables)) || isset params->variables[0]) {
            let errors[] = new RequestError("GraphQL Request parameter \"variables\" must be object or JSON string parsed to object, but got " . Utils::printSafeJson(params->getOriginalInput("variables")));
        }
        return errors;
    }
    
    /**
     * Executes GraphQL operation with given server configuration and returns execution result
     * (or promise when promise adapter is different from SyncPromiseAdapter)
     *
     * @api
     * @param ServerConfig $config
     * @param OperationParams $op
     *
     * @return ExecutionResult|Promise
     */
    public function executeOperation(<ServerConfig> config, <OperationParams> op)
    {
        var promiseAdapter, result;
    
        let promiseAdapter =  config->getPromiseAdapter() ? config->getPromiseAdapter() : Executor::getPromiseAdapter();
        let result =  this->promiseToExecuteOperation(promiseAdapter, config, op);
        if promiseAdapter instanceof SyncPromiseAdapter {
            let result =  promiseAdapter->wait(result);
        }
        return result;
    }
    
    /**
     * Executes batched GraphQL operations with shared promise queue
     * (thus, effectively batching deferreds|promises of all queries at once)
     *
     * @api
     * @param ServerConfig $config
     * @param OperationParams[] $operations
     * @return ExecutionResult[]|Promise
     */
    public function executeBatch(<ServerConfig> config, array operations)
    {
        var promiseAdapter, result, operation;
    
        let promiseAdapter =  config->getPromiseAdapter() ? config->getPromiseAdapter() : Executor::getPromiseAdapter();
        let result =  [];
        for operation in operations {
            let result[] =  this->promiseToExecuteOperation(promiseAdapter, config, operation, true);
        }
        let result =  promiseAdapter->all(result);
        // Wait for promised results when using sync promises
        if promiseAdapter instanceof SyncPromiseAdapter {
            let result =  promiseAdapter->wait(result);
        }
        return result;
    }
    
    /**
     * @param PromiseAdapter $promiseAdapter
     * @param ServerConfig $config
     * @param OperationParams $op
     * @param bool $isBatch
     * @return Promise
     */
    protected function promiseToExecuteOperation(<PromiseAdapter> promiseAdapter, <ServerConfig> config, <OperationParams> op, bool isBatch = false) -> <Promise>
    {
        var errors, doc, operationType, result, e, tmpArray6009cb13df7975962b8ed66957e95e20, tmpArrayc75978371aa490d2ca09fec9b04b7a8b, applyErrorHandling;
    
        try {
            if !(config->getSchema()) {
                throw new InvariantViolation("Schema is required for the server");
            }
            if isBatch && !(config->getQueryBatching()) {
                throw new RequestError("Batched queries are not supported by this server");
            }
            let errors =  this->validateOperationParams(op);
            if !(empty(errors)) {
                let errors =  Utils::map(errors, new HelperpromiseToExecuteOperationClosureOne());
                return promiseAdapter->createFulfilled(new ExecutionResult(null, errors));
            }
            let doc =  op->queryId ? this->loadPersistedQuery(config, op)  : op->query;
            if !(doc instanceof DocumentNode) {
                let doc =  Parser::parse(doc);
            }
            let operationType =  ast::getOperation(doc, op->operation);
            if op->isReadOnly() && operationType !== "query" {
                throw new RequestError("GET supports only query operation");
            }
            let result =  GraphQL::promiseToExecute(promiseAdapter, config->getSchema(), doc, this->resolveRootValue(config, op, doc, operationType), this->resolveContextValue(config, op, doc, operationType), op->variables, op->operation, config->getFieldResolver(), this->resolveValidationRules(config, op, doc, operationType));
        } catch RequestError, e {
            let tmpArray6009cb13df7975962b8ed66957e95e20 = [Error::createLocatedError(e)];
            let result =  promiseAdapter->createFulfilled(new ExecutionResult(null, tmpArray6009cb13df7975962b8ed66957e95e20));
        } catch Error, e {
            let tmpArrayc75978371aa490d2ca09fec9b04b7a8b = [e];
            let result =  promiseAdapter->createFulfilled(new ExecutionResult(null, tmpArrayc75978371aa490d2ca09fec9b04b7a8b));
        }
        let applyErrorHandling =  new HelperpromiseToExecuteOperationClosureOne(config);
        return result->then(applyErrorHandling);
    }
    
    /**
     * @param ServerConfig $config
     * @param OperationParams $op
     * @return mixed
     * @throws RequestError
     */
    protected function loadPersistedQuery(<ServerConfig> config, <OperationParams> op)
    {
        var loader, source;
    
        // Load query if we got persisted query id:
        let loader =  config->getPersistentQueryLoader();
        if !(loader) {
            throw new RequestError("Persisted queries are not supported by this server");
        }
        let source =  {loader}(op->queryId, op);
        if !(is_string(source)) && !(source instanceof DocumentNode) {
            throw new InvariantViolation(sprintf("Persistent query loader must return query string or instance of %s but got: %s", DocumentNode::class, Utils::printSafe(source)));
        }
        return source;
    }
    
    /**
     * @param ServerConfig $config
     * @param OperationParams $params
     * @param DocumentNode $doc
     * @param $operationType
     * @return array
     */
    protected function resolveValidationRules(<ServerConfig> config, <OperationParams> params, <DocumentNode> doc, operationType) -> array
    {
        var validationRules;
    
        // Allow customizing validation rules per operation:
        let validationRules =  config->getValidationRules();
        if is_callable(validationRules) {
            let validationRules =  {validationRules}(params, doc, operationType);
            if !(is_array(validationRules)) {
                throw new InvariantViolation(sprintf("Expecting validation rules to be array or callable returning array, but got: %s", Utils::printSafe(validationRules)));
            }
        }
        return validationRules;
    }
    
    /**
     * @param ServerConfig $config
     * @param OperationParams $params
     * @param DocumentNode $doc
     * @param $operationType
     * @return mixed
     */
    protected function resolveRootValue(<ServerConfig> config, <OperationParams> params, <DocumentNode> doc, operationType)
    {
        var root;
    
        let root =  config->getRootValue();
        if root instanceof \Closure {
            let root =  {root}(params, doc, operationType);
        }
        return root;
    }
    
    /**
     * @param ServerConfig $config
     * @param OperationParams $params
     * @param DocumentNode $doc
     * @param $operationType
     * @return mixed
     */
    protected function resolveContextValue(<ServerConfig> config, <OperationParams> params, <DocumentNode> doc, operationType)
    {
        var context;
    
        let context =  config->getContext();
        if context instanceof \Closure {
            let context =  {context}(params, doc, operationType);
        }
        return context;
    }
    
    /**
     * Send response using standard PHP `header()` and `echo`.
     *
     * @api
     * @param Promise|ExecutionResult|ExecutionResult[] $result
     * @param bool $exitWhenDone
     */
    public function sendResponse(result, bool exitWhenDone = false) -> void
    {
        if result instanceof Promise {
            result->then(new HelpersendResponseClosureOne(exitWhenDone));
        } else {
            this->doSendResponse(result, exitWhenDone);
        }
    }
    
    /**
     * @param $result
     * @param $exitWhenDone
     */
    protected function doSendResponse(result, exitWhenDone) -> void
    {
        var httpStatus;
    
        let httpStatus =  this->resolveHttpStatus(result);
        this->emitResponse(result, httpStatus, exitWhenDone);
    }
    
    /**
     * @param array|\JsonSerializable $jsonSerializable
     * @param int $httpStatus
     * @param bool $exitWhenDone
     */
    public function emitResponse(jsonSerializable, int httpStatus, bool exitWhenDone) -> void
    {
        var body;
    
        let body =  json_encode(jsonSerializable);
        header("Content-Type: application/json", true, httpStatus);
        echo body;
        if exitWhenDone {
            die;
        }
    }
    
    /**
     * @return bool|string
     */
    protected function readRawBody()
    {
        return file_get_contents("php://input");
    }
    
    /**
     * @param $result
     * @return int
     */
    protected function resolveHttpStatus(result) -> int
    {
        var httpStatus;
    
        if is_array(result) && isset result[0] {
            Utils::each(result, new HelperresolveHttpStatusClosureOne());
            let httpStatus = 200;
        } else {
            if !(result instanceof ExecutionResult) {
                throw new InvariantViolation(sprintf("Expecting query result to be instance of %s but got %s", ExecutionResult::class, Utils::printSafe(result)));
            }
            if result->data === null && !(empty(result->errors)) {
                let httpStatus = 400;
            } else {
                let httpStatus = 200;
            }
        }
        return httpStatus;
    }
    
    /**
     * Converts PSR-7 request to OperationParams[]
     *
     * @api
     * @param ServerRequestInterface $request
     * @return array|Helper
     * @throws RequestError
     */
    public function parsePsrRequest(<ServerRequestInterface> request)
    {
        var bodyParams, contentType;
    
        if request->getMethod() === "GET" {
            let bodyParams =  [];
        } else {
            let contentType =  request->getHeader("content-type");
            if !(isset contentType[0]) {
                throw new RequestError("Missing \"Content-Type\" header");
            }
            if stripos(contentType[0], "application/graphql") !== false {
                let bodyParams =  ["query" : request->getBody()->getContents()];
            } else {
                if stripos(contentType[0], "application/json") !== false {
                    let bodyParams =  request->getParsedBody();
                    if bodyParams === null {
                        throw new InvariantViolation("PSR-7 request is expected to provide parsed body for \"application/json\" requests but got null");
                    }
                    if !(is_array(bodyParams)) {
                        throw new RequestError("GraphQL Server expects JSON object or array, but got " . Utils::printSafeJson(bodyParams));
                    }
                } else {
                    let bodyParams =  request->getParsedBody();
                    if !(is_array(bodyParams)) {
                        throw new RequestError("Unexpected content type: " . Utils::printSafeJson(contentType[0]));
                    }
                }
            }
        }
        return this->parseRequestParams(request->getMethod(), bodyParams, request->getQueryParams());
    }
    
    /**
     * Converts query execution result to PSR-7 response
     *
     * @api
     * @param Promise|ExecutionResult|ExecutionResult[] $result
     * @param ResponseInterface $response
     * @param StreamInterface $writableBodyStream
     * @return Promise|ResponseInterface
     */
    public function toPsrResponse(result, <ResponseInterface> response, <StreamInterface> writableBodyStream)
    {
        if result instanceof Promise {
            return result->then(new HelpertoPsrResponseClosureOne(response, writableBodyStream));
        } else {
            return this->doConvertToPsrResponse(result, response, writableBodyStream);
        }
    }
    
    protected function doConvertToPsrResponse(result, <ResponseInterface> response, <StreamInterface> writableBodyStream)
    {
        var httpStatus;
    
        let httpStatus =  this->resolveHttpStatus(result);
        let result =  json_encode(result);
        writableBodyStream->write(result);
        return response->withStatus(httpStatus)->withHeader("Content-Type", "application/json")->withBody(writableBodyStream);
    }

}