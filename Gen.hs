module Main (main) where

import Control.Monad
import System.Environment

main :: IO ()
main = do
  [flag, moduleNumberString] <- getArgs
  let moduleNumber = read moduleNumberString
      prevModuleNumber = moduleNumber - 1
      isFirst = flag == "first"

  putStrLn $ "module " <> moduleName moduleNumber <> " where"
  putStrLn $ "import GHC.Generics"
  unless isFirst $
    putStrLn $
      "import " <> moduleName prevModuleNumber <> "()"
  putStrLn $ ""
  forM_ [0 .. 15] $ \typeNumber -> do
    renderType moduleNumber typeNumber
    putStrLn $ ""
    renderFnInit moduleNumber typeNumber
    putStrLn $ ""

moduleName :: Int -> String
moduleName moduleNumber = "M" <> show moduleNumber

typeName :: Int -> Int -> String
typeName moduleNumber typeNumber = moduleName moduleNumber <> "T" <> show typeNumber

fieldName :: Int -> Int -> Int -> String
fieldName moduleNumber typeNumber fieldNumber = "field" <> typeName moduleNumber typeNumber <> "F" <> show fieldNumber

type NameFn = Int -> Int -> String

fnInitName :: NameFn
fnInitName moduleNumber typeNumber = "fn" <> typeName moduleNumber typeNumber <> "Init"

fnSumName :: NameFn
fnSumName moduleNumber typeNumber = "fn" <> typeName moduleNumber typeNumber <> "Sum"

fnLastSumName :: NameFn
fnLastSumName moduleNumber _typeNumber = fnSumName (moduleNumber - 1) 15

renderType :: Int -> Int -> IO ()
renderType moduleNumber typeNumber = do
  putStrLn $ "data " <> typeName moduleNumber typeNumber <> " = " <> typeName moduleNumber typeNumber
  putStrLn $ "  { " <> fieldName moduleNumber typeNumber 0 <> " :: Int"
  forM_ [1 .. 15] $ \n ->
    putStrLn $ "  , " <> fieldName moduleNumber typeNumber n <> " :: Int"
  putStrLn $ "  }"
  putStrLn $ "  deriving stock (Eq, Show, Generic)"

renderFnInit :: Int -> Int -> IO ()
renderFnInit moduleNumber typeNumber = do
  let fnName = fnInitName moduleNumber typeNumber
  putStrLn $ fnName <> " :: " <> typeName moduleNumber typeNumber
  putStrLn $ fnName <> " = " <> typeName moduleNumber typeNumber
  putStrLn $ "  { " <> fieldName moduleNumber typeNumber 0 <> " = 1"
  forM_ [1 .. 15] $ \n ->
    putStrLn $ "  , " <> fieldName moduleNumber typeNumber n <> " = 1"
  putStrLn $ "  }"

renderFnSum :: NameFn -> Int -> Int -> IO ()
renderFnSum prevFn moduleNumber typeNumber = do
  let fnName = fnSumName moduleNumber typeNumber
      prevFnName = prevFn moduleNumber typeNumber
  putStrLn $ fnName <> " :: " <> typeName moduleNumber typeNumber
  putStrLn $ fnName <> " = " <> typeName moduleNumber typeNumber
  putStrLn $ "  { " <> fieldName moduleNumber typeNumber 0 <> " = " <> prevFnName <> "."
  forM_ [1 .. 15] $ \n ->
    putStrLn $ "  , " <> fieldName moduleNumber typeNumber n <> " = "
  putStrLn $ "  }"
