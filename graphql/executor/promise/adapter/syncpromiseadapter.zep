namespace GraphQL\Executor\Promise\Adapter;

use GraphQL\Deferred;
use GraphQL\Error\InvariantViolation;
use GraphQL\Executor\Promise\Promise;
use GraphQL\Executor\Promise\PromiseAdapter;
use GraphQL\Utils\Utils;
/**
 * Class SyncPromiseAdapter
 *
 * Allows changing order of field resolution even in sync environments
 * (by leveraging queue of deferreds and promises)
 *
 * @package GraphQL\Executor\Promise\Adapter
 */
class SyncPromiseAdapter implements PromiseAdapter
{
    /**
     * @inheritdoc
     */
    public function isThenable(value)
    {
        return value instanceof Deferred;
    }
    
    /**
     * @inheritdoc
     */
    public function convertThenable(thenable)
    {
        if !(thenable instanceof Deferred) {
            throw new InvariantViolation("Expected instance of GraphQL\\Deferred, got " . Utils::printSafe(thenable));
        }
        return new Promise(thenable->promise, this);
    }
    
    /**
     * @inheritdoc
     */
    public function then(<Promise> promise, onFulfilled = null, onRejected = null)
    {
        /** @var SyncPromise $promise */
        let promise =  promise->adoptedPromise;
        return new Promise(promise->then(onFulfilled, onRejected), this);
    }
    
    /**
     * @inheritdoc
     */
    public function create(resolver)
    {
        var promise, tmpArrayc1071c2844348db842590b377b983c02, tmpArraye003eb8bdc74deb2f216e0343c3abd7e, e;
    
        let promise =  new SyncPromise();
        try {
            let tmpArrayc1071c2844348db842590b377b983c02 = [promise, "resolve"];
            let tmpArraye003eb8bdc74deb2f216e0343c3abd7e = [promise, "reject"];
            {resolver}(tmpArrayc1071c2844348db842590b377b983c02, tmpArraye003eb8bdc74deb2f216e0343c3abd7e);
        } catch \Exception, e {
            promise->reject(e);
        } catch \Throwable, e {
            promise->reject(e);
        }
        return new Promise(promise, this);
    }
    
    /**
     * @inheritdoc
     */
    public function createFulfilled(value = null)
    {
        var promise;
    
        let promise =  new SyncPromise();
        return new Promise(promise->resolve(value), this);
    }
    
    /**
     * @inheritdoc
     */
    public function createRejected(reason)
    {
        var promise;
    
        let promise =  new SyncPromise();
        return new Promise(promise->reject(reason), this);
    }
    
    /**
     * @inheritdoc
     */
    public function all(array promisesOrValues)
    {
        var all, total, count, result, index, promiseOrValue, tmpArray1b44921bf5cbe710103d938aa3dcf6a2;
    
        let all =  new SyncPromise();
        let total =  count(promisesOrValues);
        let count = 0;
        let result =  [];
        for index, promiseOrValue in promisesOrValues {
            if promiseOrValue instanceof Promise {
                let result[index] = null;
                let result[index] = value;
                let count++;
                let tmpArray1b44921bf5cbe710103d938aa3dcf6a2 = [all, "reject"];
                promiseOrValue->then(new SyncPromiseAdapterallClosureOne(index, count, total, result, all), tmpArray1b44921bf5cbe710103d938aa3dcf6a2);
            } else {
                let result[index] = promiseOrValue;
                let count++;
            }
        }
        if count === total {
            all->resolve(result);
        }
        return new Promise(all, this);
    }
    
    /**
     * Synchronously wait when promise completes
     *
     * @param Promise $promise
     * @return mixed
     */
    public function wait(<Promise> promise)
    {
        var dfdQueue, promiseQueue, syncPromise;
    
        this->beforeWait(promise);
        let dfdQueue =  Deferred::getQueue();
        let promiseQueue =  SyncPromise::getQueue();
        while (promise->adoptedPromise->state === SyncPromise::PENDING && !((dfdQueue->isEmpty() && promiseQueue->isEmpty()))) {
            Deferred::runQueue();
            SyncPromise::runQueue();
            this->onWait(promise);
        }
        /** @var SyncPromise $syncPromise */
        let syncPromise =  promise->adoptedPromise;
        if syncPromise->state === SyncPromise::FULFILLED {
            return syncPromise->result;
        } else {
            if syncPromise->state === SyncPromise::REJECTED {
                throw syncPromise->result;
            }
        }
        throw new InvariantViolation("Could not resolve promise");
    }
    
    /**
     * Execute just before starting to run promise completion
     *
     * @param Promise $promise
     */
    protected function beforeWait(<Promise> promise) -> void
    {
    }
    
    /**
     * Execute while running promise completion
     *
     * @param Promise $promise
     */
    protected function onWait(<Promise> promise) -> void
    {
    }

}