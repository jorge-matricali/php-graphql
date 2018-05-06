namespace GraphQL\Error;

use GraphQL\Language\AST\Node;
use GraphQL\Language\Source;
use GraphQL\Language\SourceLocation;
use GraphQL\Utils\Utils;
/**
 * Describes an Error found during the parse, validate, or
 * execute phases of performing a GraphQL operation. In addition to a message
 * and stack trace, it also includes information about the locations in a
 * GraphQL document and/or execution result that correspond to the Error.
 *
 * When the error was caused by an exception thrown in resolver, original exception
 * is available via `getPrevious()`.
 *
 * Also read related docs on [error handling](error-handling.md)
 *
 * Class extends standard PHP `\Exception`, so all standard methods of base `\Exception` class
 * are available in addition to those listed below.
 */
class Error extends \Exception implements \JsonSerializable, ClientAware
{
    const CATEGORY_GRAPHQL = "graphql";
    const CATEGORY_INTERNAL = "internal";
    /**
     * A message describing the Error for debugging purposes.
     *
     * @var string
     */
    public message;
    /**
     * @var SourceLocation[]
     */
    protected locations;
    /**
     * An array describing the JSON-path into the execution response which
     * corresponds to this error. Only included for errors during execution.
     *
     * @var array
     */
    public path;
    /**
     * An array of GraphQL AST Nodes corresponding to this error.
     *
     * @var array
     */
    public nodes;
    /**
     * The source GraphQL document for the first location of this error.
     *
     * Note that if this Error represents more than one node, the source may not
     * represent nodes after the first node.
     *
     * @var Source|null
     */
    protected source;
    /**
     * @var array
     */
    protected positions;
    /**
     * @var bool
     */
    protected isClientSafe;
    /**
     * @var string
     */
    protected category;
    /**
     * @var array
     */
    protected extensions;
    /**
     * Given an arbitrary Error, presumably thrown while attempting to execute a
     * GraphQL operation, produce a new GraphQLError aware of the location in the
     * document responsible for the original Error.
     *
     * @param $error
     * @param array|null $nodes
     * @param array|null $path
     * @return Error
     */
    public static function createLocatedError(error, nodes = null, path = null) -> <\Error>
    {
        var source, positions, originalError, extensions, message;
    
        if error instanceof self {
            if error->path && error->nodes {
                return error;
            } else {
                let nodes =  nodes ? nodes : error->nodes;
                let path =  path ? path : error->path;
            }
        }
        let source = null;
        let originalError = null;
        let positions = null;
        ;
        let extensions =  [];
        if error instanceof self {
            let message =  error->getMessage();
            let originalError = error;
            let nodes =  error->nodes ? error->nodes : nodes;
            let source =  error->source;
            let positions =  error->positions;
            let extensions =  error->extensions;
        } else {
            if error instanceof \Exception || error instanceof \Throwable {
                let message =  error->getMessage();
                let originalError = error;
            } else {
                let message =  (string) error;
            }
        }
        return new static( message ? message : "An unknown error occurred.", nodes, source, positions, path, originalError, extensions);
    }
    
    /**
     * @param Error $error
     * @return array
     */
    public static function formatError(<Error> error) -> array
    {
        return error->toSerializableArray();
    }
    
    /**
     * @param string $message
     * @param array|Node|null $nodes
     * @param Source $source
     * @param array|null $positions
     * @param array|null $path
     * @param \Throwable $previous
     * @param array $extensions
     */
    public function __construct(string message, nodes = null, <Source> source = null, positions = null, path = null, previous = null, array extensions = []) -> void
    {
        parent::__construct(message, 0, previous);
        // Compute list of blame nodes.
        if nodes instanceof \Traversable {
            let nodes =  iterator_to_array(nodes);
        } else {
            if nodes && !(is_array(nodes)) {
                let nodes =  [nodes];
            }
        }
        let this->nodes = nodes;
        let this->source = source;
        let this->positions = positions;
        let this->path = path;
        let this->extensions =  extensions ? extensions : ( previous && previous instanceof self ? previous->extensions  : []);
        if previous instanceof ClientAware {
            let this->isClientSafe =  previous->isClientSafe();
            let this->category =  previous->getCategory() ? previous->getCategory() : static::CATEGORY_INTERNAL;
        } else {
            if previous {
                let this->isClientSafe =  false;
                let this->category =  static::CATEGORY_INTERNAL;
            } else {
                let this->isClientSafe =  true;
                let this->category =  static::CATEGORY_GRAPHQL;
            }
        }
    }
    
    /**
     * @inheritdoc
     */
    public function isClientSafe() -> bool
    {
        return this->isClientSafe;
    }
    
    /**
     * @inheritdoc
     */
    public function getCategory() -> string
    {
        return this->category;
    }
    
    /**
     * @return Source|null
     */
    public function getSource()
    {
        if this->source === null {
            if !(empty(this->nodes[0])) && !(empty(this->nodes[0]->loc)) {
                let this->source =  this->nodes[0]->loc->source;
            }
        }
        return this->source;
    }
    
    /**
     * @return array
     */
    public function getPositions() -> array
    {
        var positions;
    
        if this->positions === null {
            if !(empty(this->nodes)) {
                let positions =  array_map(new ErrorgetPositionsClosureOne(), this->nodes);
                let this->positions =  array_filter(positions, new ErrorgetPositionsClosureOne());
            }
        }
        return this->positions;
    }
    
    /**
     * An array of locations within the source GraphQL document which correspond to this error.
     *
     * Each entry has information about `line` and `column` within source GraphQL document:
     * $location->line;
     * $location->column;
     *
     * Errors during validation often contain multiple locations, for example to
     * point out to field mentioned in multiple fragments. Errors during execution include a
     * single location, the field which produced the error.
     *
     * @api
     * @return SourceLocation[]
     */
    public function getLocations() -> array
    {
        var positions, source, nodes;
    
        if this->locations === null {
            let positions =  this->getPositions();
            let source =  this->getSource();
            let nodes =  this->nodes;
            if positions && source {
                let this->locations =  array_map(new ErrorgetLocationsClosureOne(source), positions);
            } else {
                if nodes {
                    let this->locations =  array_filter(array_map(new ErrorgetLocationsClosureOne(), nodes));
                } else {
                    let this->locations =  [];
                }
            }
        }
        return this->locations;
    }
    
    /**
     * @return array|Node[]|null
     */
    public function getNodes()
    {
        return this->nodes;
    }
    
    /**
     * Returns an array describing the path from the root value to the field which produced this error.
     * Only included for execution errors.
     *
     * @api
     * @return array|null
     */
    public function getPath()
    {
        return this->path;
    }
    
    /**
     * @return array
     */
    public function getExtensions() -> array
    {
        return this->extensions;
    }
    
    /**
     * Returns array representation of error suitable for serialization
     *
     * @deprecated Use FormattedError::createFromException() instead
     * @return array
     */
    public function toSerializableArray() -> array
    {
        var arr, locations;
    
        let arr =  ["message" : this->getMessage()];
        if this->getExtensions() {
            let arr =  array_merge(this->getExtensions(), arr);
        }
        let locations =  Utils::map(this->getLocations(), new ErrortoSerializableArrayClosureOne());
        if !(empty(locations)) {
            let arr["locations"] = locations;
        }
        if !(empty(this->path)) {
            let arr["path"] = this->path;
        }
        return arr;
    }
    
    /**
     * Specify data which should be serialized to JSON
     * @link http://php.net/manual/en/jsonserializable.jsonserialize.php
     * @return mixed data which can be serialized by <b>json_encode</b>,
     * which is a value of any type other than a resource.
     * @since 5.4.0
     */
    function jsonSerialize()
    {
        return this->toSerializableArray();
    }
    
    /**
     * @return string
     */
    public function __toString() -> string
    {
        return FormattedError::printError(this);
    }

}