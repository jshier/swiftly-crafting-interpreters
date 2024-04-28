import Benchmark
import SloxKit

let interpreter = Interpreter()

let benchmarks = {
    Benchmark("Interpret") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(interpreter.interpret())
        }
    }
}
