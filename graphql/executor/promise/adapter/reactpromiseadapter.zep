namespace GraphQL\Executor\Promise\Adapter;

use GraphQL\Executor\Promise\Promise;
use GraphQL\Executor\Promise\PromiseAdapter;
use GraphQL\Utils\Utils;
use React\Promise\Promise as ReactPromise;
use React\Promise\PromiseInterface as ReactPromiseInterface;
class ReactPromiseAdapter implements PromiseAdapter
{
    /**
     * @inheritdoc
     */
    public function isThenable(value)
    {
        return value instanceof ReactPromiseInterface;
    }
    
    /**
     * @inheritdoc
     */
    public function convertThenable(thenable)
    {
        return new Promise(thenable, this);
    }
    
    /**
     * @inheritdoc
     */
    public function then(<Promise> promise, onFulfilled = null, onRejected = null)
    {
        var adoptedPromise;
    
        /** @var $adoptedPromise ReactPromiseInterface */
        let adoptedPromise =  promise->adoptedPromise;
        return new Promise(adoptedPromise->then(onFulfilled, onRejected), this);
    }
    
    /**
     * @inheritdoc
     */
    public function create(resolver)
    {
        var promise;
    
        let promise =  new ReactPromise(resolver);
        return new Promise(promise, this);
    }
    
    /**
     * @inheritdoc
     */
    public function createFulfilled(value = null)
    {
        var promise;
    
        let promise =  \React\Promise\resolve(value);
        return new Promise(promise, this);
    }
    
    /**
     * @inheritdoc
     */
    public function createRejected(reason)
    {
        var promise;
    
        let promise =  \React\Promise\reject(reason);
        return new Promise(promise, this);
    }
    
    /**
     * @inheritdoc
     */
    public function all(array promisesOrValues)
    {
        var promise, orderedResults, key, value;
    
        // TODO: rework with generators when PHP minimum required version is changed to 5.5+
        let promisesOrValues =  Utils::map(promisesOrValues, new ReactPromiseAdapterallClosureOne());
        let orderedResults =  [];
        let orderedResults[key] = values[key];
        let promise =  \React\Promise\all(promisesOrValues)->then(new ReactPromiseAdapterallClosureOne(promisesOrValues));
        return new Promise(promise, this);
    }

}